require 'curses_menu'

CursesMenu.new 'My awesome new menu!' do |menu|
  menu.item 'How\'s life?' do
    puts 'Couldn\'t be easier'
    :menu_exit
  end
end
