require 'curses'
require 'curses_menu/curses_row'

# Provide a menu using curses with keys navigation and selection
class CursesMenu

  # Define some color pairs names.
  # The integer value is meaningless in itself but they all have to be different.
  COLORS_TITLE = 1
  COLORS_LINE = 2
  COLORS_MENU_ITEM = 3
  COLORS_MENU_ITEM_SELECTED = 4
  COLORS_INPUT = 5
  COLORS_GREEN = 6
  COLORS_RED = 7
  COLORS_YELLOW = 8
  COLORS_BLUE = 9
  COLORS_WHITE = 10

  # curses keys that are not defined by Curses, but that are returned by getch
  KEY_ENTER = 10
  KEY_ESCAPE = 27

  # Constructor.
  # Display a list of choices, ask for user input and execute the choice made.
  # Repeat the operation unless one of the code returns the :menu_exit symbol.
  #
  # Parameters::
  # * *title* (String): Title of those choices
  # * *key_presses* (Array<Object>): List of key presses to automatically apply [default: []]
  #   Can be characters or ascii values, as returned by curses' getch.
  #   The list is modified in place along with its consumption, so that it can be reused in sub-menus if needed.
  # * *&menu_items_def* (Proc): Code to be called to get the list of choices. This code can call the following methods to design the menu:
  #   * Parameters::
  #     * *menu* (CursesMenu): The CursesMenu instance
  def initialize(title, key_presses: [], &menu_items_def)
    @current_menu_items = nil
    @curses_initialized = false
    current_items = gather_menu_items(&menu_items_def)
    selected_idx = 0
    raise "Menu #{title} has no items to select" if selected_idx.nil?

    window = curses_menu_initialize
    begin
      max_displayed_items = window.maxy - 5
      display_first_idx = 0
      display_first_char_idx = 0
      loop do
        # TODO: Don't redraw fixed items for performance
        # Display the title
        window.setpos(0, 0)
        print(window, '', default_color_pair: COLORS_TITLE, pad: '=')
        print(window, "= #{title}", default_color_pair: COLORS_TITLE, pad: ' ', single_line: true)
        print(window, '', default_color_pair: COLORS_TITLE, pad: '-')
        # Display the menu
        current_items[display_first_idx..display_first_idx + max_displayed_items - 1].each.with_index do |item_info, idx|
          selected = display_first_idx + idx == selected_idx
          print(
            window,
            item_info[:title],
            from: display_first_char_idx,
            default_color_pair: item_info.key?(:actions) ? COLORS_MENU_ITEM : COLORS_LINE,
            force_color_pair: selected ? COLORS_MENU_ITEM_SELECTED : nil,
            pad: selected ? ' ' : nil,
            single_line: true
          )
        end
        # Display the footer
        window.setpos(window.maxy - 2, 0)
        print(window, '', default_color_pair: COLORS_TITLE, pad: '=')
        display_actions = {
          'Arrows/Home/End' => 'Navigate',
          'Esc' => 'Exit'
        }
        if current_items[selected_idx][:actions]
          display_actions.merge!(
            current_items[selected_idx][:actions].to_h do |action_shortcut, action_info|
              [
                case action_shortcut
                when KEY_ENTER
                  'Enter'
                else
                  action_shortcut
                end,
                action_info[:name]
              ]
            end
          )
        end
        print(
          window,
          "= #{display_actions.sort.map { |(shortcut, name)| "#{shortcut}: #{name}" }.join(' | ')}",
          from: display_first_char_idx,
          default_color_pair: COLORS_TITLE,
          pad: ' ',
          add_nl: false,
          single_line: true
        )
        window.refresh
        user_choice = nil
        loop do
          user_choice = key_presses.empty? ? window.getch : key_presses.shift
          break unless user_choice.nil?

          sleep 0.01
        end
        case user_choice
        when Curses::KEY_RIGHT
          display_first_char_idx += 1
        when Curses::KEY_LEFT
          display_first_char_idx -= 1
        when Curses::KEY_UP
          selected_idx -= 1
        when Curses::KEY_PPAGE
          selected_idx -= max_displayed_items - 1
        when Curses::KEY_DOWN
          selected_idx += 1
        when Curses::KEY_NPAGE
          selected_idx += max_displayed_items - 1
        when Curses::KEY_HOME
          selected_idx = 0
        when Curses::KEY_END
          selected_idx = current_items.size - 1
        when KEY_ESCAPE
          break
        else
          # Check actions
          if current_items[selected_idx][:actions]&.key?(user_choice)
            curses_menu_finalize
            result = current_items[selected_idx][:actions][user_choice][:execute].call
            if result.is_a?(Symbol)
              case result
              when :menu_exit
                break
              when :menu_refresh
                current_items = gather_menu_items(&menu_items_def)
              end
            end
            window = curses_menu_initialize
            window.clear
          end
        end
        # Stay in bounds
        display_first_char_idx = 0 if display_first_char_idx.negative?
        selected_idx = current_items.size - 1 if selected_idx >= current_items.size
        selected_idx = 0 if selected_idx.negative?
        if selected_idx < display_first_idx
          display_first_idx = selected_idx
        elsif selected_idx >= display_first_idx + max_displayed_items
          display_first_idx = selected_idx - max_displayed_items + 1
        end
      end
    ensure
      curses_menu_finalize
    end
  end

  # Register a new menu item.
  # This method is meant to be called from a choose_from call.
  #
  # Parameters::
  # * *title* (String or CursesRow): Text to be displayed for this item
  # * *actions* (Hash<Object, Hash<Symbol,Object> >): Associated actions to this item, per shortcut [default: {}]
  #   * *name* (String): Name of this action (displayed at the bottom of the menu)
  #   * *execute* (Proc): Code called when this action is selected
  # * *&action* (Proc): Code called if the item is selected (action for the enter key) [optional].
  #   * Result::
  #     * Symbol or Object: If the code returns a symbol, the menu will behave in a specific way:
  #       * *menu_exit*: the menu selection exits.
  #       * *menu_refresh*: The menu will compute again its items.
  def item(title, actions: {}, &action)
    menu_item_def = { title: title }
    all_actions = action.nil? ? actions : actions.merge(KEY_ENTER => { name: 'Select', execute: action })
    menu_item_def[:actions] = all_actions unless all_actions.empty?
    @current_menu_items << menu_item_def
  end

  private

  # Display a given curses string information.
  #
  # Parameters::
  # * *window* (Window): The curses window in which we display.
  # * *string* (String or CursesRow): The curses row, or as a single String.
  # * See CursesRow#print_on for all the other parameters description
  def print(window, string, from: 0, to: nil, default_color_pair: COLORS_LINE, force_color_pair: nil, pad: nil, add_nl: true, single_line: false)
    string = CursesRow.new({ default: { text: string } }) if string.is_a?(String)
    string.print_on(
      window,
      from: from,
      to: to,
      default_color_pair: default_color_pair,
      force_color_pair: force_color_pair,
      pad: pad,
      add_nl: add_nl,
      single_line: single_line
    )
  end

  # Initialize and get the curses menu window
  #
  # Result::
  # * Window: The curses menu window
  def curses_menu_initialize
    Curses.init_screen
    # Use non-blocking key read, otherwise using Popen3 later blocks
    Curses.timeout = 0
    Curses.start_color
    Curses.init_pair(COLORS_TITLE, Curses::COLOR_BLACK, Curses::COLOR_CYAN)
    Curses.init_pair(COLORS_LINE, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_MENU_ITEM, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_MENU_ITEM_SELECTED, Curses::COLOR_BLACK, Curses::COLOR_WHITE)
    Curses.init_pair(COLORS_INPUT, Curses::COLOR_WHITE, Curses::COLOR_BLUE)
    Curses.init_pair(COLORS_GREEN, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_RED, Curses::COLOR_RED, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_YELLOW, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_BLUE, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS_WHITE, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
    window = Curses.stdscr
    window.keypad = true
    @curses_initialized = true
    window
  end

  # Finalize the curses menu window
  def curses_menu_finalize
    Curses.close_screen if @curses_initialized
    @curses_initialized = false
  end

  # Get menu items.
  #
  # Parameters::
  # * Proc: Code defining the menu items
  #   * *menu* (CursesMenu): The menu for which we gather items.
  # Result::
  # * Array< Hash<Symbol,Object> >: List of items to be displayed
  #   * *title* (String): Item title to display
  #   * *actions* (Hash<Object, Hash<Symbol,Object> >): Associated actions to this item, per shortcut [optional]
  #     * *name* (String): Name of this action (displayed at the bottom of the menu)
  #     * *execute* (Proc): Code called when this action is selected
  def gather_menu_items
    @current_menu_items = []
    yield self
    @current_menu_items
  end

end
