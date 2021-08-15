describe CursesMenu do

  it 'does not span items on more than 1 line' do
    nbr_visible_chars = Curses.stdscr.maxx
    test_menu do |menu|
      menu.item '1' * nbr_visible_chars * 2
      menu.item 'Menu item 2'
    end
    assert_line 3, '1' * (nbr_visible_chars - 1)
    assert_line 4, 'Menu item 2'
  end

  it 'scrolls by using right key' do
    nbr_visible_chars = Curses.stdscr.maxx
    test_menu(keys: [Curses::KEY_RIGHT, Curses::KEY_RIGHT, Curses::KEY_RIGHT]) do |menu|
      menu.item "abcde#{'1' * (nbr_visible_chars - 5)}23456789"
    end
    assert_line 3, "de#{'1' * (nbr_visible_chars - 5)}23"
  end

  it 'scrolls by using left key' do
    nbr_visible_chars = Curses.stdscr.maxx
    test_menu(keys: [Curses::KEY_RIGHT, Curses::KEY_RIGHT, Curses::KEY_RIGHT, Curses::KEY_LEFT]) do |menu|
      menu.item "abcde#{'1' * (nbr_visible_chars - 5)}23456789"
    end
    assert_line 3, "cde#{'1' * (nbr_visible_chars - 5)}2"
  end

  it 'scrolls by using down key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_NPAGE, Curses::KEY_DOWN, Curses::KEY_DOWN]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, 'Menu item 2'
    assert_line(-3, "Menu item #{nbr_visible_items + 1}")
  end

  it 'scrolls by using up key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END, Curses::KEY_PPAGE, Curses::KEY_UP, Curses::KEY_UP]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, "Menu item #{nbr_visible_items - 2}"
    assert_line(-3, "Menu item #{2 * nbr_visible_items - 3}")
  end

  it 'scrolls by using page down key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_NPAGE, Curses::KEY_NPAGE]) do |menu|
      (nbr_visible_items * 3).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, "Menu item #{nbr_visible_items - 1}"
    assert_line(-3, "Menu item #{nbr_visible_items * 2 - 2}")
  end

  it 'scrolls by using page up key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END, Curses::KEY_PPAGE, Curses::KEY_PPAGE]) do |menu|
      (nbr_visible_items * 3).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, "Menu item #{nbr_visible_items + 2 - 1}"
    assert_line(-3, "Menu item #{nbr_visible_items * 2}")
  end

  it 'scrolls by using end key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, "Menu item #{nbr_visible_items}"
    assert_line(-3, "Menu item #{nbr_visible_items * 2 - 1}")
  end

  it 'scrolls by using home key' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END, Curses::KEY_HOME]) do |menu|
      (nbr_visible_items * 3).times do |idx|
        menu.item "Menu item #{idx}"
      end
    end
    assert_line 3, 'Menu item 0'
    assert_line(-3, "Menu item #{nbr_visible_items - 1}")
  end

end
