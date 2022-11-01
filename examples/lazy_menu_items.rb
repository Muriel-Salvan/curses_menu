require 'curses_menu'

nbr_visible_items = Curses.stdscr.maxy - 5
CursesMenu.new 'Menu items using lazy rendering' do |menu|
  (nbr_visible_items * 2).times do
    menu.item "[Rendered at #{Time.now}] - I am a normal item"
    menu.item(proc do
      "[Rendered at #{Time.now}] - I am a lazy item"
    end)
    menu.item(
      "[Rendered at #{Time.now}] - I am a normal item with lazy rendered action",
      actions: proc do
        {
          'a' => {
            name: "Action rendered at #{Time.now}",
            execute: proc {}
          }
        }
      end
    )
  end
  menu.item 'Refresh menu' do
    :menu_refresh
  end
end
