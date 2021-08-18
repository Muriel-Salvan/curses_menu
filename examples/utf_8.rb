require 'curses_menu'

CursesMenu.new 'My awesome new menu! - 私の素晴らしい新しいメニュー' do |menu|
  menu.item 'How\'s life? - 人生はどうですか？' do
    puts 'Couldn\'t be easier - 簡単なことはありません'
    :menu_exit
  end
end
