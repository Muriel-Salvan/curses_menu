describe CursesMenu do

  it 'displays a menu with 1 item with lazy rendering' do
    render_called = false
    test_menu do |menu|
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
    test_menu do |menu|
      menu.item(proc do
        render_called = true
        CursesMenu::CursesRow.new({ cell: { text: 'Menu item lazy' } })
      end)
    end
    expect(render_called).to be true
    assert_line 3, 'Menu item lazy'
  end

  it 'displays menu actions with lazy evaluation' do
    render_called = false
    action_executed = false
    test_menu(keys: ['a']) do |menu|
      menu.item('Menu item lazy', actions: proc do
        render_called = true
        {
          'a' => {
            name: 'Lazy action',
            execute: proc do
              action_executed = true
            end
          }
        }
      end)
    end
    assert_line 3, 'Menu item lazy'
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Lazy action')
    expect(render_called).to be true
    expect(action_executed).to be true
  end

  it 'displays menu actions with lazy evaluation and a default action' do
    render_called = false
    action_executed = false
    default_executed = false
    test_menu(keys: ['a', CursesMenu::KEY_ENTER]) do |menu|
      menu.item(
        'Menu item lazy',
        actions: proc do
          render_called = true
          {
            'a' => {
              name: 'Lazy action',
              execute: proc do
                action_executed = true
              end
            }
          }
        end
      ) do
        default_executed = true
      end
    end
    assert_line 3, 'Menu item lazy'
    assert_line(-1, '= Arrows/Home/End: Navigate | Enter: Select | Esc: Exit | a: Lazy action')
    expect(render_called).to be true
    expect(action_executed).to be true
    expect(default_executed).to be true
  end

  it 'doesn\'t lazy render when the item is not displayed' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    render_called = false
    test_menu do |menu|
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

  it 'doesn\'t lazy evaluate actions when the item is not displayed' do
    nbr_visible_items = Curses.stdscr.maxy - 5
    render_called = false
    test_menu do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
      menu.item('Menu item lazy', actions: proc do
        render_called = true
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
      end)
    end
    expect(render_called).to be false
  end

  it 'doesn\'t lazy evaluate actions when the item is not selected' do
    render_called = false
    test_menu do |menu|
      menu.item 'Menu item'
      menu.item('Menu item lazy', actions: proc do
        render_called = true
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
      end)
    end
    expect(render_called).to be false
  end

  it 'lazy evaluates actions as soon as the item is selected' do
    render_called = false
    test_menu(keys: [Curses::KEY_DOWN]) do |menu|
      menu.item 'Menu item'
      menu.item('Menu item lazy', actions: proc do
        render_called = true
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
      end)
    end
    expect(render_called).to be true
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

  it 'keeps lazy evaluated actions in a cache while navigating' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN, Curses::KEY_DOWN]) do |menu|
      menu.item 'Menu item 1'
      menu.item('Menu item 2 lazy', actions: proc do
        nbr_renders += 1
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
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

  it 'keeps lazy evaluated actions in a cache while navigating across pages' do
    nbr_renders = 0
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN, Curses::KEY_END, Curses::KEY_HOME, Curses::KEY_END, Curses::KEY_HOME, Curses::KEY_END]) do |menu|
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
      menu.item('Menu item lazy', actions: proc do
        nbr_renders += 1
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
      end)
    end
    expect(nbr_renders).to eq 1
    assert_line(-1, '= Arrows/Home/End: Navigate | Esc: Exit | a: Lazy action')
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

  it 'refreshes lazy evaluated actions between menu refreshes' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_UP, CursesMenu::KEY_ENTER, Curses::KEY_DOWN, Curses::KEY_UP]) do |menu|
      menu.item 'Menu item Refresh' do
        :menu_refresh
      end
      menu.item('Menu item lazy', actions: proc do
        nbr_renders += 1
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
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

  it 'does not refresh lazy evaluated actions when executing actions' do
    nbr_renders = 0
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_UP, CursesMenu::KEY_ENTER, Curses::KEY_DOWN, Curses::KEY_UP]) do |menu|
      menu.item 'Menu item' do
        # Do nothing
      end
      menu.item('Menu item lazy', actions: proc do
        nbr_renders += 1
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
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

  it 'does not refresh lazy evaluated actions when getting into sub-menus' do
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
      menu.item('Menu item lazy', actions: proc do
        nbr_renders += 1
        {
          'a' => {
            name: 'Lazy action',
            execute: proc {}
          }
        }
      end)
    end
    expect(nbr_renders).to eq 1
  end

  it 'always lazy renders titles before lazy evaluating actions' do
    lazy_renders = []
    nbr_visible_items = Curses.stdscr.maxy - 5
    test_menu(keys: [Curses::KEY_END, Curses::KEY_HOME, Curses::KEY_DOWN]) do |menu|
      menu.item(
        proc do
          lazy_renders << :item_1_title
          'Menu item 1 lazy'
        end,
        actions: proc do
          lazy_renders << :item_1_action
          { 'a' => { name: 'Lazy action 1', execute: proc {} } }
        end
      )
      menu.item(
        proc do
          lazy_renders << :item_2_title
          'Menu item 2 lazy'
        end,
        actions: proc do
          lazy_renders << :item_2_action
          { 'a' => { name: 'Lazy action 2', execute: proc {} } }
        end
      )
      (nbr_visible_items * 2).times do |idx|
        menu.item "Menu item #{idx}"
      end
      menu.item(
        proc do
          lazy_renders << :item_3_title
          'Menu item 3 lazy'
        end,
        actions: proc do
          lazy_renders << :item_3_action
          { 'a' => { name: 'Lazy action 3', execute: proc {} } }
        end
      )
    end
    expect(lazy_renders).to eq %i[item_1_title item_2_title item_1_action item_3_title item_3_action item_2_action]
  end

end
