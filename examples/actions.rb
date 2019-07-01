require 'curses_menu'

nbr = 0
CursesMenu.new 'Items can have several actions. Look at the footer!' do |menu|
  menu.item "Current number is #{nbr} - Use a or d", actions: {
    'd' => {
      name: 'Increase',
      execute: proc do
        nbr += 1
        :menu_refresh
      end
    },
    'a' => {
      name: 'Decrease',
      execute: proc do
        nbr -= 1
        :menu_refresh
      end
    }
  }
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
