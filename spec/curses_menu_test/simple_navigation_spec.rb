describe CursesMenu do

  it 'displays a menu with 1 item' do
    test_menu(title: 'Menu title') do |menu|
      menu.item 'Menu item'
    end
    assert_line 1, '= Menu title'
    assert_line 3, 'Menu item'
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit')
  end

  it 'displays a menu with several items' do
    test_menu do |menu|
      menu.item 'Menu item 1'
      menu.item 'Menu item 2'
      menu.item 'Menu item 3'
    end
    assert_line 3, 'Menu item 1'
    assert_line 4, 'Menu item 2'
    assert_line 5, 'Menu item 3'
  end

  it 'displays a menu item with more actions' do
    test_menu do |menu|
      menu.item 'Menu item', actions: {
        'a' => {
          name: 'First action',
          execute: proc {}
        },
        'b' => {
          name: 'Second action',
          execute: proc {}
        }
      }
    end
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: First action | b: Second action')
  end

  it 'navigates by using down key' do
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN]) do |menu|
      menu.item 'Menu item 1'
      menu.item 'Menu item 2'
      menu.item 'Menu item 3', actions: { 'a' => { name: 'Special action', execute: proc {} } }
      menu.item 'Menu item 4'
    end
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Special action')
  end

  it 'navigates by using end key' do
    test_menu(keys: [Curses::KEY_END]) do |menu|
      menu.item 'Menu item 1'
      menu.item 'Menu item 2'
      menu.item 'Menu item 3'
      menu.item 'Menu item 4', actions: { 'a' => { name: 'Special action', execute: proc {} } }
    end
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Special action')
  end

  it 'navigates by using up key' do
    test_menu(keys: [Curses::KEY_END, Curses::KEY_UP]) do |menu|
      menu.item 'Menu item 1'
      menu.item 'Menu item 2'
      menu.item 'Menu item 3', actions: { 'a' => { name: 'Special action', execute: proc {} } }
      menu.item 'Menu item 4'
    end
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Special action')
  end

  it 'navigates by using home key' do
    test_menu(keys: [Curses::KEY_END, Curses::KEY_HOME]) do |menu|
      menu.item 'Menu item 1', actions: { 'a' => { name: 'Special action', execute: proc {} } }
      menu.item 'Menu item 2'
      menu.item 'Menu item 3'
      menu.item 'Menu item 4'
    end
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Special action')
  end

  it 'navigates by using right key' do
    test_menu(keys: [Curses::KEY_RIGHT, Curses::KEY_RIGHT]) do |menu|
      menu.item 'Menu item'
    end
    assert_line 3, 'nu item'
    assert_line(-1, 'Arrows/Home/End: Navigate | Esc: Exit')
  end

  it 'navigates by using left key' do
    test_menu(keys: [Curses::KEY_RIGHT, Curses::KEY_RIGHT, Curses::KEY_LEFT]) do |menu|
      menu.item 'Menu item'
    end
    assert_line 3, 'enu item'
    assert_line(-1, ' Arrows/Home/End: Navigate | Esc: Exit')
  end

  it 'navigates by using page down key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_NPAGE]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        if idx == nbr_visible_items - 1
          menu.item "Menu item #{idx}", actions: { 'a' => { name: "Special action #{idx}", execute: proc {} } }
        else
          menu.item "Menu item #{idx}"
        end
      end
    end
    assert_line(-1, "= Arrows/Home/End: Navigate | Esc: Exit | a: Special action #{nbr_visible_items - 1}")
  end

  it 'navigates by using page up key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END, Curses::KEY_PPAGE]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        if idx == nbr_visible_items
          menu.item "Menu item #{idx}", actions: { 'a' => { name: "Special action #{idx}", execute: proc {} } }
        else
          menu.item "Menu item #{idx}"
        end
      end
    end
    assert_line(-1, "= Arrows/Home/End: Navigate | Esc: Exit | a: Special action #{nbr_visible_items}")
  end

end
