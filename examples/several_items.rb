require 'curses_menu'

CursesMenu.new 'We have several items, some of them have no action' do |menu|
  menu.item 'Nothing to do with me'
  menu.item 'Select me - I\'m option A!' do
    puts 'You have selected A. Press enter to continue.'
    $stdin.gets
  end
  menu.item 'Or select me - Option B!' do
    puts 'You have selected B. Press enter to continue.'
    $stdin.gets
  end
  menu.item '---- Separator'
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
