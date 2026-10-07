//! A small Ratatui program for the termshot-action guide: the jobs of a CI run,
//! with their status, and a gauge of how many have passed.

use ratatui::layout::{Constraint, Layout};
use ratatui::style::{Color, Modifier, Style, Stylize};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Gauge, List, ListItem};
use ratatui::Frame;

pub struct Job {
    pub name: &'static str,
    pub status: Status,
}

#[derive(Clone, Copy, PartialEq)]
pub enum Status {
    Passed,
    Failed,
    Running,
}

pub struct App {
    pub jobs: Vec<Job>,
}

impl App {
    pub fn all_passed() -> App {
        let mut app = App::new();
        for job in &mut app.jobs {
            job.status = Status::Passed;
        }
        app
    }

    pub fn new() -> App {
        App {
            jobs: vec![
                Job { name: "build (linux)", status: Status::Passed },
                Job { name: "build (macos)", status: Status::Passed },
                Job { name: "test (unit)", status: Status::Failed },
                Job { name: "test (integration)", status: Status::Running },
            ],
        }
    }
}

pub fn ui(frame: &mut Frame, app: &App) {
    let [list, gauge] = Layout::vertical([Constraint::Min(3), Constraint::Length(3)]).areas(frame.area());
    let items: Vec<ListItem> = app
        .jobs
        .iter()
        .map(|job| {
            let (mark, color) = match job.status {
                Status::Passed => ("✓", Color::Green),
                Status::Failed => ("✗", Color::Red),
                Status::Running => ("●", Color::Yellow),
            };
            let name = if job.status == Status::Failed { job.name.bold() } else { job.name.into() };
            ListItem::new(Line::from(vec![Span::styled(format!(" {mark} "), Style::new().fg(color)), name]))
        })
        .collect();
    let block = Block::bordered().border_type(BorderType::Rounded).title(" CI run #42 ".cyan().bold());
    frame.render_widget(List::new(items).block(block), list);
    let passed = app.jobs.iter().filter(|j| j.status == Status::Passed).count();
    let ratio = passed as f64 / app.jobs.len() as f64;
    let gauge_widget = Gauge::default()
        .block(Block::bordered().border_type(BorderType::Rounded).title(" passed "))
        .gauge_style(Style::new().fg(Color::Green).bg(Color::DarkGray).add_modifier(Modifier::BOLD))
        .ratio(ratio)
        .label(format!("{passed}/{}", app.jobs.len()));
    frame.render_widget(gauge_widget, gauge);
}

fn main() -> std::io::Result<()> {
    let app = App::new();
    let mut terminal = ratatui::init();
    loop {
        terminal.draw(|frame| ui(frame, &app))?;
        if let ratatui::crossterm::event::Event::Key(_) = ratatui::crossterm::event::read()? {
            break;
        }
    }
    ratatui::restore();
    Ok(())
}

#[cfg(test)]
mod tests;
