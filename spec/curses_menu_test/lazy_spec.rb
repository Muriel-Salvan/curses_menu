describe CursesMenu do

  it 'displays a menu with 1 item with lazy rendering' do
    render_called = false
    test_menu(title: 'Menu title') do |menu|
      menu.item(proc do
        render_called = true
        'Menu item lazy'
      end)
    end
    expect(render_called).to be true
    assert_line 3, 'Menu item lazy'
  end

  it 'displays a menu with 1 item in a CursesRow with lazy rendering' do
    render_called = false
    test_menu(title: 'Menu title') do |menu|
      menu.item(proc do
        render_called = true
        CursesMenu::CursesRow.new({ cell: { text: 'Menu item lazy' } })
      end)
    end
    expect(render_called).to be true
    assert_line 3, 'Menu item lazy'
  end

  it 'doesn\'t lazy render when the item is not displayed' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    render_called = false
    test_menu(title: 'Menu title') do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
      menu.item(proc do
        render_called = true
        'Menu item lazy'
      end)
    end
    expect(render_called).to be false
  end

  it 'keeps lazy rendered titles in a cache while navigating' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN, Curses::KEY_DOWN]) do |menu|
      menu.item 'Menu item 1'
      menu.item(proc do
        nbr_renders += 1
        'Menu item 2 Lazy'
      end)
      menu.item 'Menu item 3'
      menu.item 'Menu item 4', actions: { 'a' => { name: 'Special action', execute: proc {} } }
    end
    expect(nbr_renders).to eq 1
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Special action')
  end

  it 'keeps lazy rendered titles in a cache while navigating across pages' do
    nbr_renders = 0
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN, Curses::KEY_END, Curses::KEY_HOME, Curses::KEY_END, Curses::KEY_HOME, Curses::KEY_END]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
      menu.item(proc do
        nbr_renders += 1
        'Menu item Lazy'
      end)
    end
    expect(nbr_renders).to eq 1
    assert_line(-3, 'Menu item Lazy')
  end

  it 'refreshes lazy rendered titles between menu refreshes' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_UP, CursesMenu::KEY_ENTER, Curses::KEY_DOWN, Curses::KEY_UP]) do |menu|
      menu.item 'Menu item Refresh' do
        :menu_refresh
      end
      menu.item(proc do
        nbr_renders += 1
        'Menu item Lazy'
      end)
    end
    expect(nbr_renders).to eq 2
  end

  it 'does not refresh lazy rendered titles when executing actions' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_UP, CursesMenu::KEY_ENTER, Curses::KEY_DOWN, Curses::KEY_UP]) do |menu|
      menu.item 'Menu item' do
        # Do nothing
      end
      menu.item(proc do
        nbr_renders += 1
        'Menu item Lazy'
      end)
    end
    expect(nbr_renders).to eq 1
  end

  it 'does not refresh lazy rendered titles when getting into sub-menus' do
    nbr_renders = 0
    test_menu(
      keys: [
        # Enter sub-menu
        CursesMenu::KEY_ENTER,
        Curses::KEY_DOWN,
        # Back to first menu
        CursesMenu::KEY_ESCAPE,
        Curses::KEY_DOWN
      ]
    ) do |menu, key_presses|
      menu.item 'Sub-menu' do
        described_class.new('Sub-menu title', key_presses: key_presses) do |sub_menu|
          sub_menu.item 'Sub-menu item 1'
          sub_menu.item 'Sub-menu item 2'
        end
      end
      menu.item(proc do
        nbr_renders += 1
        'Menu item Lazy'
      end)
    end
    expect(nbr_renders).to eq 1
  end

end
