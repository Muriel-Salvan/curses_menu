require 'curses_menu'

nbr = 0
switch = false
CursesMenu.new 'Menu being refreshed when selecting things' do |menu|
  menu.item "Current number is #{nbr} - Select me for +1" do
    nbr += 1
    :menu_refresh
  end
  menu.item "Current number is #{nbr} - Select me for -1" do
    nbr -= 1
    :menu_refresh
  end
  menu.item "[#{switch ? '*' : ' '}] Switch me!" do
    switch = !switch
    :menu_refresh
  end
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
