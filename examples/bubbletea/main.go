// A small Bubble Tea program for the termshot-action guide: an inbox you move
// through with the arrow keys and open with enter.
package main

import (
	"fmt"
	"os"
	"strings"

	tea "charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
)

var (
	frame    = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("#5fd7d7")).Padding(0, 1)
	title    = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("#5fd7d7"))
	selected = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("#111823")).Background(lipgloss.Color("#dbe7f7"))
	unread   = lipgloss.NewStyle().Foreground(lipgloss.Color("#ffd75f"))
	help     = lipgloss.NewStyle().Faint(true)
)

type model struct {
	items  []string
	unread map[int]bool
	cursor int
	opened string
}

func newModel() model {
	return model{
		items:  []string{"Welcome to the team", "Invoice #1042", "Build failed on main", "Lunch on Friday?"},
		unread: map[int]bool{1: true, 2: true},
	}
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if key, ok := msg.(tea.KeyPressMsg); ok {
		switch key.String() {
		case "up", "k":
			m.cursor = (m.cursor + len(m.items) - 1) % len(m.items)
		case "down", "j":
			m.cursor = (m.cursor + 1) % len(m.items)
		case "enter":
			m.opened = m.items[m.cursor]
			delete(m.unread, m.cursor)
		case "q", "ctrl+c":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m model) View() tea.View {
	var b strings.Builder
	b.WriteString(title.Render("Inbox") + "\n\n")
	for i, item := range m.items {
		line := "  " + item
		if m.unread[i] {
			line = unread.Render("● ") + item
		}
		if i == m.cursor {
			line = selected.Render(fmt.Sprintf("▸ %-24s", item))
		}
		b.WriteString(line + "\n")
	}
	status := help.Render("↑/↓ move · enter open · q quit")
	if m.opened != "" {
		status = "Opened " + title.Render(m.opened)
	}
	return tea.NewView(frame.Render(b.String()) + "\n" + status + "\n")
}

func main() {
	if _, err := tea.NewProgram(newModel()).Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
