class_name RunDefinition
extends Resource
## References use Resource so malformed authoring can receive field diagnostics.
## The validator establishes their precise definition types before runtime use.

@export var schema_version: int = 1
@export var player: Resource
@export var enemy: Resource
@export var weapon: Resource
@export var arena: Resource
@export var spawn_interval: float = 1.5
@export var max_live_enemies: int = 50
@export var camera_yaw: float = 0.0
@export var camera_depression: float = 35.0
@export var depression_min: float = 15.0
@export var depression_max: float = 65.0
@export var camera_distance: float = 8.0
@export var camera_target_height: float = 1.2
@export var mouse_sensitivity: float = 0.12
@export var camera_fov: float = 70.0
