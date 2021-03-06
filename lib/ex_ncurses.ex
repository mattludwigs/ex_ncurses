defmodule ExNcurses do
  alias ExNcurses.{Getstr, Server}

  @moduledoc """
  ExNcurses lets Elixir programs create text-based user interfaces using ncurses.

  Aside from keyboard input, ExNcurses looks almost like a straight translation of the C-based
  ncurses API. ExNcurses sends key events via messages. See `listen/0` for this.

  Ncurses documentation can be found at:
  * [The ncurses project page](https://www.gnu.org/software/ncurses/)
  * [opengroup.org](http://pubs.opengroup.org/onlinepubs/7908799/xcurses/curses.h.html)
  * [] for ncurses documentation.
  """

  @type pair :: non_neg_integer()
  @type color_name :: :black | :red | :green | :yellow | :blue | :magenta | :cyan | :white
  @type color :: 0..7 | color_name()
  @type window :: reference()

  def fun(:F1), do: 265
  def fun(:F2), do: 266
  def fun(:F3), do: 267
  def fun(:F4), do: 268
  def fun(:F5), do: 269
  def fun(:F6), do: 270
  def fun(:F7), do: 271
  def fun(:F8), do: 272
  def fun(:F9), do: 273
  def fun(:F10), do: 274
  def fun(:F11), do: 275
  def fun(:F12), do: 276

  @doc """
  Initialize ncurses on a terminal. This should be called before any of the
  other functions.

  By default, ncurses uses the current terminal. If you're debugging or want to
  have IEx available while in ncurses-mode you can also have it use a different
  window. One way of doing this is to open up another terminal session. At the
  prompt, run `tty`. Then pass the path that it returns to this function.
  Currently input doesn't work in this mode.

  TODO: Return stdscr (a window)
  """
  @spec initscr(String.t()) :: :ok
  defdelegate initscr(termname \\ ""), to: Server

  @doc """
  Stop using ncurses and clean the terminal back up.
  """
  @spec endwin() :: :ok
  defdelegate endwin(), to: Server

  @doc """
  Print the specified string and advance the cursor.
  Unlike the ncurses printw, this version doesn't support format
  specification. It is really the same as `addstr/1`.
  """
  @spec printw(String.t()) :: :ok
  def printw(s), do: Server.invoke(:printw, {s})

  @spec addstr(String.t()) :: :ok
  def addstr(s), do: Server.invoke(:addstr, {s})

  @spec mvprintw(non_neg_integer(), non_neg_integer(), String.t()) :: :ok
  def mvprintw(y, x, s), do: Server.invoke(:mvprintw, {y, x, s})

  @spec mvaddstr(non_neg_integer(), non_neg_integer(), String.t()) :: :ok
  def mvaddstr(y, x, s), do: Server.invoke(:mvaddstr, {y, x, s})

  @doc """
  Draw a border around the current window.
  """
  @spec border() :: :ok
  def border(), do: Server.invoke(:border, {})

  @doc """
  Draw a wborder around a specific window.
  """
  @spec wborder(window()) :: :ok
  def wborder(w), do: Server.invoke(:wborder, {w})

  @doc """
  Move the cursor to the new location.
  """
  @spec mvcur(non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()) :: :ok
  def mvcur(oldrow, oldcol, newrow, newcol),
    do: Server.invoke(:mvcur, {oldrow, oldcol, newrow, newcol})

  @doc """
  Refresh the display. This needs to be called after any of the print or
  addstr functions to render their changes.
  """
  @spec refresh() :: :ok
  def refresh(), do: Server.invoke(:refresh)

  @spec wrefresh(window()) :: :ok
  def wrefresh(w), do: Server.invoke(:wrefresh, {w})

  @doc """
  Clear the screen
  """
  @spec clear() :: :ok
  def clear(), do: Server.invoke(:clear)

  @spec wclear(window()) :: :ok
  def wclear(w), do: Server.invoke(:wclear, {w})

  @spec raw() :: :ok
  def raw(), do: Server.invoke(:raw)

  @spec cbreak() :: :ok
  def cbreak(), do: Server.invoke(:cbreak)

  @spec nocbreak() :: :ok
  def nocbreak(), do: Server.invoke(:nocbreak)

  @spec noecho() :: :ok
  def noecho(), do: Server.invoke(:noecho)

  @spec beep() :: :ok
  def beep(), do: Server.invoke(:beep)

  @doc """
  Set the cursor mode

  * 0 = Invisible
  * 1 = Terminal-specific normal mode
  * 2 = Terminal-specific high visibility mode
  """
  @spec curs_set(0..2) :: :ok
  def curs_set(visibility), do: Server.invoke(:curs_set, {visibility})

  @doc """
  Return the cursor's column.
  """
  @spec getx() :: non_neg_integer()
  def getx(), do: Server.invoke(:getx)

  @doc """
  Return the cursor's row.
  """
  @spec gety() :: non_neg_integer()
  def gety(), do: Server.invoke(:gety)

  @spec flushinp() :: :ok
  def flushinp(), do: Server.invoke(:flushinp)

  @doc """
  Enable the terminal's keypad to capture function keys as single characters.
  """
  @spec keypad() :: :ok
  def keypad(), do: Server.invoke(:keypad)

  @doc """
  Enable scrolling on `stdscr`.
  """
  @spec scrollok() :: :ok
  def scrollok(), do: Server.invoke(:scrollok)

  @doc """
  Enable the use of colors.
  """
  @spec start_color() :: :ok
  def start_color(), do: Server.invoke(:start_color)

  @doc """
  Return whether the display supports color
  """
  @spec has_colors() :: boolean()
  def has_colors(), do: Server.invoke(:has_colors)

  @doc """
  Initialize a foreground/background color pair
  """
  @spec init_pair(pair(), color(), color()) :: :ok
  def init_pair(pair, f, b),
    do: Server.invoke(:init_pair, {pair, color_to_number(f), color_to_number(b)})

  @doc """
  Turn on the bit-masked attribute values pass in on the current screen.
  """
  @spec attron(pair()) :: :ok
  def attron(pair), do: Server.invoke(:attron, {pair})

  @doc """
  Turn off the bit-masked attribute values pass in on the current screen.
  """
  @spec attroff(pair()) :: :ok
  def attroff(pair), do: Server.invoke(:attroff, {pair})

  @doc """
  Set a scrollable region on the `stdscr`
  """
  @spec setscrreg(non_neg_integer(), non_neg_integer()) :: :ok
  def setscrreg(top, bottom), do: Server.invoke(:setscrreg, {top, bottom})

  @doc """
  Create a new window with number of nlines, number columns, starting y position, and
  starting x position.
  """
  @spec newwin(non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          window()
  def newwin(nlines, ncols, begin_y, begin_x),
    do: Server.invoke(:newwin, {nlines, ncols, begin_y, begin_x})

  @doc """
  Delete a window `w`. This cleans up all memory resources associated with it. The application
  must delete subwindows before deleteing the main window.
  """
  @spec delwin(window()) :: :ok
  def delwin(w), do: Server.invoke(:delwin, {w})

  @doc """
  Add a string to a window `win`. This function will advance the cursor position,
  perform special character processing, and perform wrapping.
  """
  @spec waddstr(window(), String.t()) :: :ok
  def waddstr(win, str), do: Server.invoke(:waddstr, {win, str})

  @doc """
  Move the cursor associated with the specified window to (y, x) relative to the window's orgin.
  """
  @spec wmove(window(), non_neg_integer(), non_neg_integer()) :: :ok
  def wmove(win, y, x), do: Server.invoke(:wmove, {win, y, x})

  @doc """
  Move the cursor for the current window to (y, x) relative to the window's orgin.
  """
  @spec move(non_neg_integer(), non_neg_integer()) :: :ok
  def move(y, x), do: Server.invoke(:move, {y, x})

  @doc """
  Return the number of visible columns
  """
  @spec cols() :: non_neg_integer()
  def cols(), do: Server.invoke(:cols)

  @doc """
  Return the number of visible lines
  """
  @spec lines() :: non_neg_integer()
  def lines(), do: Server.invoke(:lines)

  @doc """
  Poll for a key press.

  See `listen/0` for a better way of getting keyboard input.
  """
  def getch() do
    listen()

    c =
      receive do
        {:ex_ncurses, :key, key} -> key
      end

    stop_listening()
    c
  end

  @doc """
  Poll for a string.
  """
  def getstr() do
    listen()

    noecho()

    str = getstr_loop(Getstr.init(gety(), getx(), 60))

    stop_listening()
    str
  end

  defp getstr_loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        case Getstr.process(state, key) do
          {:done, str} ->
            str

          {:not_done, new_state} ->
            getstr_loop(new_state)
        end
    end
  end

  # Common initialization
  def n_begin() do
    initscr()
    raw()
    cbreak()
  end

  def n_end() do
    nocbreak()
    endwin()
  end

  @doc """
  Listen for events.

  Events will be sent as messages of the form:

  `{ex_ncurses, :key, key}`
  """
  defdelegate listen(), to: Server

  @doc """
  Stop listening for events
  """
  defdelegate stop_listening(), to: Server

  defp color_to_number(x) when is_integer(x), do: x
  defp color_to_number(:black), do: 0
  defp color_to_number(:red), do: 1
  defp color_to_number(:green), do: 2
  defp color_to_number(:yellow), do: 3
  defp color_to_number(:blue), do: 4
  defp color_to_number(:magenta), do: 5
  defp color_to_number(:cyan), do: 6
  defp color_to_number(:white), do: 7
end
