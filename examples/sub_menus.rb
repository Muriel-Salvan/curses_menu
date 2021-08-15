require 'curses_menu'

CursesMenu.new 'Top menu' do |menu|
  menu.item 'Enter menu 1' do
    CursesMenu.new 'Sub-menu 1' do |sub_menu|
      sub_menu.item 'We are in sub-menu 1'
      sub_menu.item('Back') { :menu_exit }
    end
  end
  menu.item 'Enter menu 2' do
    CursesMenu.new 'Sub-menu 2' do |sub_menu|
      sub_menu.item 'We are in sub-menu 2'
      sub_menu.item('Back') { :menu_exit }
    end
  end
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
