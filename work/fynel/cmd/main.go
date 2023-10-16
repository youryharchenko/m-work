package main

import (
	"context"
	"fmt"
	"log"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"

	"github.com/neo4j/neo4j-go-driver/v5/neo4j"
	"github.com/pelletier/go-toml"
)

type Env struct {
	Url      string
	Username string
	Password string
	Database string
	Ctx      context.Context
	Driver   neo4j.DriverWithContext
}

func (env *Env) Close() {
	if err := env.Driver.Close(env.Ctx); err != nil {
		log.Println(fmt.Errorf("could not close resource: %w", err))
	}
}

func OpenEnv(confPath string) (env *Env, err error) {
	if confPath == "" {
		confPath = "conf.toml"
	}

	tree, err := toml.LoadFile(confPath)
	if err != nil {
		return
	}

	env = new(Env)
	env.Ctx = context.Background()
	if url := tree.Get("Neo4j.url"); url != nil {
		env.Url = url.(string)
	} else {
		env.Url = "bolt://localhost"
	}
	if user := tree.Get("Neo4j.user"); user != nil {
		env.Username = user.(string)
	} else {
		env.Username = "Neo4j"
	}
	if pwd := tree.Get("Neo4j.pwd"); pwd != nil {
		env.Password = pwd.(string)
	} else {
		env.Password = ""
	}
	if db := tree.Get("Neo4j.database"); db != nil {
		env.Database = db.(string)
	} else {
		env.Database = "neo4j"
	}

	drv, err := neo4j.NewDriverWithContext(env.Url,
		neo4j.BasicAuth(env.Username, env.Password, ""))
	if err != nil {
		return
	}
	env.Driver = drv

	return

}

const preferenceCurrentTutorial = "currentTutorial"

func main() {

	a := app.NewWithID("info.ai-r.fynel") //app.New()

	w := a.NewWindow("FynEL")

	content := container.NewStack()
	title := widget.NewLabel("Component name")
	intro := widget.NewLabel("An introduction would probably go\nhere, as well as a")
	intro.Wrapping = fyne.TextWrapWord

	setTutorial := func(t RightContent) {

		title.SetText(t.Title)
		intro.SetText(t.Intro)

		content.Objects = []fyne.CanvasObject{t.View(w)}
		content.Refresh()
	}

	rcontent := container.NewBorder(
		container.NewVBox(title, widget.NewSeparator(), intro), nil, nil, nil, content)
	appSplit := container.NewHSplit(makeNav(setTutorial, true), rcontent)

	appSplit.Offset = 0.3
	w.SetContent(appSplit)
	w.Resize(fyne.NewSize(1024, 720))
	w.ShowAndRun()

}

func makeNav(setTutorial func(rcontent RightContent), loadPrevious bool) fyne.CanvasObject {
	a := fyne.CurrentApp()

	tree := &widget.Tree{
		ChildUIDs: func(uid string) []string {
			return RightContentIndex[uid]
		},
		IsBranch: func(uid string) bool {
			children, ok := RightContentIndex[uid]

			return ok && len(children) > 0
		},
		CreateNode: func(branch bool) fyne.CanvasObject {
			return widget.NewLabel("Collection Widgets")
		},
		UpdateNode: func(uid string, branch bool, obj fyne.CanvasObject) {
			t, ok := RightContents[uid]
			if !ok {
				fyne.LogError("Missing tutorial panel: "+uid, nil)
				return
			}
			obj.(*widget.Label).SetText(t.Title)
			if unsupportedTutorial(t) {
				obj.(*widget.Label).TextStyle = fyne.TextStyle{Italic: true}
			} else {
				obj.(*widget.Label).TextStyle = fyne.TextStyle{}
			}
		},
		OnSelected: func(uid string) {
			if t, ok := RightContents[uid]; ok {
				if unsupportedTutorial(t) {
					return
				}
				a.Preferences().SetString(preferenceCurrentTutorial, uid)
				setTutorial(t)
			}
		},
	}

	if loadPrevious {
		currentPref := a.Preferences().StringWithFallback(preferenceCurrentTutorial, "welcome")
		tree.Select(currentPref)
	}

	themes := container.NewGridWithColumns(2,
		widget.NewButton("Dark", func() {
			a.Settings().SetTheme(theme.DarkTheme())
		}),
		widget.NewButton("Light", func() {
			a.Settings().SetTheme(theme.LightTheme())
		}),
	)

	return container.NewBorder(nil, themes, nil, nil, tree)
}

func unsupportedTutorial(t RightContent) bool {
	return !t.SupportWeb && fyne.CurrentDevice().IsBrowser()
}
