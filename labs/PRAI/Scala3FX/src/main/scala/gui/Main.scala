package gui

import scalafx.Includes.*

import scalafx.application.JFXApp3
import scalafx.application.JFXApp3.PrimaryStage
import scalafx.scene.Scene
import scalafx.scene.layout.BorderPane
import scalafx.scene.layout.VBox
import scalafx.scene.control.*
import scalafx.scene.input.KeyCombination
import scalafx.scene.shape.*
import scalafx.scene.paint.Color
import scalafx.geometry.Orientation
import scalafx.scene.layout.HBox

object Main extends JFXApp3 {
  val initWidth = 1024.0
  val initHeight = 720.0

  override def start(): Unit = {

    stage = new PrimaryStage {
      scene = new Scene(initWidth, initHeight) {
        
        root = new BorderPane {
          top = new VBox {
            children = List(
              createMenus(),
              createToolBar()
            )
            //center = createContent()
          }
          center = createContent()
          bottom = new HBox {
             children = List(
                new Label("Ready...")
             )
          }
        }
      }
      title = "Програмування систем штучного інтелекту"
    }
  }
  
  private def createContent(): SplitPane = {
    val pane = new SplitPane {
      
      items ++= List(
        new TreeView[String] {

        },
        new TabPane {

        }
      )

      
    }

    pane.dividerPositions(0) = 0.33
    println(pane.dividerPositions(0))

    pane
    
  }

  private def createMenus() = new MenuBar {
    menus = List(
      new Menu("File") {
        items = List(
          new MenuItem("New...") {
            //graphic = new ImageView(new Image(this, "images/paper.png"))
            accelerator = KeyCombination.keyCombination("Ctrl +N")
            onAction = e => println(s"${e.eventType} occurred on MenuItem New")
          },
          new MenuItem("Save")
        )
      },
      new Menu("Edit") {
        items = List(
          new MenuItem("Cut"),
          new MenuItem("Copy"),
          new MenuItem("Paste")
        )
      }
    )
  }
}

private def createToolBar(): ToolBar = {
    val alignToggleGroup = new ToggleGroup()
    val toolBar = new ToolBar {
      content = List(
        new Button {
          id = "newButton"
          //graphic = new ImageView(new Image(this, "images/paper.png"))
          tooltip = Tooltip("New Document... Ctrl+N")
          onAction = () => println("New toolbar button clicked")
        },
        new Button {
          id = "editButton"
          graphic = new Circle {
            fill = Color.Green
            radius = 8
          }
        },
        new Button {
          id = "deleteButton"
          graphic = new Circle {
            fill = Color.Blue
            radius = 8
          }
        },
        new Separator {
          orientation = Orientation.Vertical
        },
        new ToggleButton {
          id = "boldButton"
          graphic = new Circle {
            fill = Color.Maroon
            radius = 8
          }
          onAction = e => {
            val tb = e.getTarget.asInstanceOf[javafx.scene.control.ToggleButton]
            print(s"${e.eventType} occurred on ToggleButton ${tb.id}")
            print(", and selectedProperty is: ")
            println(tb.selectedProperty.value)
          }
        },
        new ToggleButton {
          id = "italicButton"
          graphic = new Circle {
            fill = Color.Yellow
            radius = 8
          }
          onAction = e => {
            val tb = e.getTarget.asInstanceOf[javafx.scene.control.ToggleButton]
            print(s"${e.eventType} occurred on ToggleButton ${tb.id}")
            print(", and selectedProperty is: ")
            println(tb.selectedProperty.value)
          }
        },
        new Separator {
          orientation = Orientation.Vertical
        },
        new ToggleButton {
          id = "leftAlignButton"
          toggleGroup = alignToggleGroup
          graphic = new Circle {
            fill = Color.Purple
            radius = 8
          }
        },
        new ToggleButton {
          toggleGroup = alignToggleGroup
          id = "centerAlignButton"
          graphic = new Circle {
            fill = Color.Orange
            radius = 8
          }
        },
        new ToggleButton {
          toggleGroup = alignToggleGroup
          id = "rightAlignButton"
          graphic = new Circle {
            fill = Color.Cyan
            radius = 8
          }
        }
      )
    }

    alignToggleGroup.selectToggle(alignToggleGroup.toggles(0))
    alignToggleGroup.selectedToggle.onChange {
      val tb = alignToggleGroup.selectedToggle.get.asInstanceOf[javafx.scene.control.ToggleButton]
      println(tb.id() + " selected")
    }

    toolBar
  }
