extends Node
# using Godot;
# using System;
#
# public partial class Settings : Node {
# 	public static Settings Singleton;
# 	[Signal]
# 	public delegate void DebugModeToggledEventHandler(bool val);
#
# 	[Export]
# 	public bool DebugMode { 
# 		get => _debugMode; 
# 		set {
# 			_debugMode = value;
# 			EmitSignal(SignalName.DebugModeToggled, value);
# 		}
# 	} 
# 	private bool _debugMode = true;
#
# 	public Settings() {
# 		Singleton = this;
# 	}
# }
