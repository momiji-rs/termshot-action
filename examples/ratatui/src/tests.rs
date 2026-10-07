use super::*;
use ratatui::backend::{CrosstermBackend, TestBackend};
use ratatui::layout::Rect;
use ratatui::{Terminal, TerminalOptions, Viewport};
use std::cell::RefCell;
use std::rc::Rc;

/// What a terminal would receive for one frame of `app`, escape sequences and
/// all: Ratatui's own crossterm backend, writing into memory instead of a
/// terminal. termshot replays these bytes into a screenshot.
fn ansi(width: u16, height: u16, app: &App) -> Vec<u8> {
    #[derive(Clone, Default)]
    struct Shared(Rc<RefCell<Vec<u8>>>);

    impl std::io::Write for Shared {
        fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
            self.0.borrow_mut().extend_from_slice(bytes);
            Ok(bytes.len())
        }

        fn flush(&mut self) -> std::io::Result<()> {
            Ok(())
        }
    }

    let out = Shared::default();
    // A fixed viewport, so the terminal never asks the (absent) real one its size.
    let viewport = Viewport::Fixed(Rect::new(0, 0, width, height));
    let mut terminal = Terminal::with_options(CrosstermBackend::new(out.clone()), TerminalOptions { viewport }).unwrap();
    terminal.draw(|frame| ui(frame, app)).unwrap();
    let bytes = out.0.borrow().clone();
    bytes
}

/// The usual Ratatui snapshot: the text of the screen, without its colours.
fn text(width: u16, height: u16, app: &App) -> TestBackend {
    let mut terminal = Terminal::new(TestBackend::new(width, height)).unwrap();
    terminal.draw(|frame| ui(frame, app)).unwrap();
    terminal.backend().clone()
}

#[test]
fn a_failed_run() {
    let app = App::new();
    insta::assert_snapshot!(text(40, 10, &app));
    insta::assert_binary_snapshot!("failed_run.ansi", ansi(40, 10, &app));
}

#[test]
fn a_run_that_passed() {
    let app = App::all_passed();
    insta::assert_snapshot!(text(40, 10, &app));
    insta::assert_binary_snapshot!("passed_run.ansi", ansi(40, 10, &app));
}
