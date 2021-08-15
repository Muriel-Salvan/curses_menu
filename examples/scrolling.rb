require 'curses_menu'

CursesMenu.new 'Use all arrows, Page up/down, Home and End keys!' do |menu|
  menu.item('Quit') { :menu_exit }
  menu.item 'That\'s a big menu item! ' * 20
  1000.times do |idx|
    menu.item "Menu item #{idx}"
  end
end
