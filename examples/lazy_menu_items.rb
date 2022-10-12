require 'curses_menu'

nbr_visible_items = Curses.stdscr.maxy - 5
CursesMenu.new 'Menu items using lazy rendering' do |menu|
  (nbr_visible_items * 2).times do
    menu.item "I am a normal item, rendered at #{Time.now}"
    menu.item(proc do
      "I am a lazy item, rendered at   #{Time.now}"
    end)
  end
  menu.item 'Refresh menu' do
    :menu_refresh
  end
end
