package main

import (
	"io"
	"testing"
	"time"

	tea "charm.land/bubbletea/v2"
	"github.com/charmbracelet/colorprofile"
	"github.com/charmbracelet/x/exp/teatest/v2"
)

// newTestModel runs the inbox the way its golden files need it to be
// screenshot: a fixed size (the size termshot is given), true colour (a test
// has no terminal to detect colours from), and a fixed TERM. Without that,
// Bubble Tea writes the same screen with different escape sequences on
// different machines, and a golden made on one fails on another.
func newTestModel(t *testing.T) *teatest.TestModel {
	return teatest.NewTestModel(t, newModel(),
		teatest.WithInitialTermSize(48, 12),
		teatest.WithProgramOptions(
			tea.WithColorProfile(colorprofile.TrueColor),
			tea.WithEnvironment([]string{"TERM=xterm-256color"}),
		),
	)
}

// finalOutput is everything the program wrote. Nothing else may read
// tm.Output() first: what it reads is gone from the golden file.
func finalOutput(t *testing.T, tm *teatest.TestModel) []byte {
	out, err := io.ReadAll(tm.FinalOutput(t, teatest.WithFinalTimeout(3*time.Second)))
	if err != nil {
		t.Fatal(err)
	}
	return out
}

func TestInbox(t *testing.T) {
	tm := newTestModel(t)
	tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"})
	teatest.RequireEqualOutput(t, finalOutput(t, tm))
}

func TestInboxOpen(t *testing.T) {
	tm := newTestModel(t)
	tm.Send(tea.KeyPressMsg{Code: tea.KeyDown})
	tm.Send(tea.KeyPressMsg{Code: tea.KeyDown})
	tm.Send(tea.KeyPressMsg{Code: tea.KeyEnter})
	tm.Send(tea.KeyPressMsg{Code: 'q', Text: "q"})
	teatest.RequireEqualOutput(t, finalOutput(t, tm))
}
