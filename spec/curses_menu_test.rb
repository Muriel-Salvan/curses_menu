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
      chars.map(&:chr).each_slice(window.maxx).map(&:join)
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
    # * *expectation* (String): The expected line
    def assert_line(line_idx, expectation)
      # Add an ending space to make sure the line does not continue after what we test
      expect(@screenshot[line_idx][0..expectation.size]).to eq("#{expectation} "), "Screenshot line #{line_idx} differs:\n  \"#{@screenshot[line_idx][0..expectation.size]}\" should be\n  \"#{expectation} \""
    end

  end

end

class CursesMenu
  prepend CursesMenuTest::CursesMenuPatch
end

