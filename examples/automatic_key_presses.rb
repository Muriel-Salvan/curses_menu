require 'curses_menu'

keys = [
  # Select first
  CursesMenu::KEY_ENTER,
  # Select second
  Curses::KEY_DOWN,
  'a',
  'b',
  # Select third (sub-menu)
  Curses::KEY_DOWN,
  CursesMenu::KEY_ENTER,
  # Select sub-menu first
  CursesMenu::KEY_ENTER,
  # Exit sub-menu
  CursesMenu::KEY_ESCAPE,
  # Navigate a bit
  Curses::KEY_NPAGE,
  Curses::KEY_HOME,
  # Select last
  Curses::KEY_END,
  CursesMenu::KEY_ENTER
]
CursesMenu.new('Menu being used automatically', key_presses: keys) do |menu|
  menu.item 'Simple item' do
    puts 'Selected a simple item'
  end
  menu.item 'Several actions on this item', actions: {
    'a' => {
      name: 'Action A',
      execute: proc { puts 'Selected action A' }
    },
    'b' => {
      name: 'Action B',
      execute: proc { puts 'Selected action B' }
    }
  }
  menu.item 'Sub-menu' do
    CursesMenu.new('Sub-menu!', key_presses: keys) do |sub_menu|
      sub_menu.item 'Simple sub-menu item' do
        puts 'Selected item from sub-menu'
      end
    end
  end
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
