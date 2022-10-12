require 'curses_menu'

module CursesMenuTest

  # Monkey-patch the curses_menu_finalize method so that it captures the menu screen before finalizing
  module CursesMenuPatch

    # Last screenshot taken
    # Array<String>: List of lines
    attr_reader :screenshot

    # Finalize the curses menu window
    def curses_menu_finalize
      @screenshot = capture_screenshot
      super
    end

    private

    # Get a screenshot of the menu
    #
    # Result::
    # * Array<String>: List of lines
    def capture_screenshot
      # Curses is initialized
      window = Curses.stdscr
      old_x = window.curx
      old_y = window.cury
      chars = []
      window.maxy.times do |idx_y|
        window.maxx.times do |idx_x|
          window.setpos idx_y, idx_x
          chars << window.inch
        end
      end
      window.setpos old_y, old_x
      # Build the map of colors per color pair acutally registered
      colors_left_shift = Curses::A_COLOR.to_s(2).match(/^1+(0+)$/)[1].size
      color_pairs = CursesMenu.constants.select { |const| const.to_s.start_with?('COLORS_') }.map do |const|
        color_pair = CursesMenu.const_get(const)
        [
          # On Windows using Curses.color_pair can result in bugs [BUG] Unnormalized Fixnum value when using/displaying the value.
          # So for now we depend on the internal algorithm used by color_pair (which is a left shift of the 0 bits of A_COLOR mask)
          # TODO: Uncomment the following when curses will be fixed on Windows
          # Curses.color_pair(color_pair),
          color_pair << colors_left_shift,
          const
        ]
      end.to_h
      chars.
        map do |chr|
          {
            char: begin
              (chr & Curses::A_CHARTEXT).chr(Encoding::UTF_8)
            rescue RangeError
              # On Windows curses returns wrong encoded characters.
              # In this case we just force an ASCII version of it.
              (chr & 255).chr(Encoding::UTF_8)
            end,
            color: color_pairs[chr & Curses::A_COLOR] || (chr & Curses::A_COLOR),
            attributes: chr & Curses::A_ATTRIBUTES
          }
        end.
        each_slice(window.maxx).
        to_a
    end

  end

  # Helpers for the tests
  module Helpers

    # Test a given menu, and prepare a screenshot to be analyzed
    #
    # Parameters::
    # * *title* (String): The title [default: 'Menu title']
    # * *keys* (Array<Object> or nil): Keys to automatically press [default: []]
    # * *auto_exit* (Boolean): Do we automatically add the escape key to the key presses? [default: true]
    # * Proc: The code called with the test menu to be populated
    #   * Parameters::
    #     * *menu* (CursesMenu): Curses menu to populate
    #     * *key_presses* (Array<Object>): Keys to possibly give to sub-menus
    def test_menu(title: 'Menu title', keys: [], auto_exit: true)
      # TODO: Find a way to not depend on the current terminal screen, and run the tests silently.
      key_presses = auto_exit ? keys + [CursesMenu::KEY_ESCAPE] : keys
      menu = CursesMenu.new(title, key_presses: key_presses) do |m|
        yield m, key_presses
      end
      @screenshot = menu.screenshot
    end

    # Assert that a line of the screenshot starts with a given content
    #
    # Parameters::
    # * *line_idx* (Integer): The line index of the screenshot
    # * *expectation* (String or Regexp): The expected line
    def assert_line(line_idx, expectation)
      line = @screenshot[line_idx][0..(expectation.is_a?(Regexp) ? -1 : expectation.size)].map { |char_info| char_info[:char] }.join
      if expectation.is_a?(Regexp)
        expect(line).to match(expectation), "Screenshot line #{line_idx} differs:\n  \"#{line}\" should be\n  \"#{expectation} \""
      else
        # Add an ending space to make sure the line does not continue after what we test
        expect(line).to eq("#{expectation} "), "Screenshot line #{line_idx} differs:\n  \"#{line}\" should be\n  \"#{expectation} \""
      end
    end

    # Assert that a line of the screenshot starts with a given content, using colors information
    #
    # Parameters::
    # * *line_idx* (Integer): The line index of the screenshot
    # * *expectation* (String): The expected line
    # * *color* (Symbol): The expected color pair name
    def assert_colored_line(line_idx, expectation, color)
      colored_line = @screenshot[line_idx][0..expectation.size - 1].map do |char_info|
        [char_info[:char], char_info[:color]]
      end
      expected_colored_line = expectation.each_char.map do |chr|
        [chr, color]
      end
      expect(colored_line).to eq(expected_colored_line), "Screenshot line #{line_idx} differs:\n  \"#{colored_line}\" should be\n  \"#{expected_colored_line}\""
    end

  end

end

class CursesMenu

  prepend CursesMenuTest::CursesMenuPatch

end
