name         := "PRAI"
organization := "YouryHarchenko"
version      := "0.1-SNAPSHOT"

scalaVersion := "3.2.2"

libraryDependencies ++= Seq(
  "org.scalafx"   %% "scalafx"   % "20.0.0-R31",
  "org.scalatest" %% "scalatest" % "3.2.15" % "test"
)

// Fork a new JVM for 'run' and 'test:run' to avoid JavaFX double initialization problems
fork := true

//scalacOptions ++= Seq("-new-syntax", "-rewrite")
//scalacOptions ++= Seq("-indent", "-rewrite")

// set the main class for the main 'run' task
// change Compile to Test to set it for 'test:run'
//Compile / run / mainClass := Some("gui.Main")
//Compile / resourceDirectory := baseDirectory(_ / "src").value
//Compile / scalaSource := baseDirectory(_ / "src").value