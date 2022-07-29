extends Node

export var TICK_RATE = 30 # 1/s

# For developers to set from the outside, for example:
#   Online.nakama_host = 'nakama.example.com'
#   Online.nakama_scheme = 'https'
var nakama_server_key: String = 'R3O6FUCYMX64P1I4LIZYXGDU9T90X5XF'
var nakama_host: String = 'nilolo.de'
var nakama_port: int = 7350
var nakama_scheme: String = 'https'

# For other scripts to access:
var nakama_client: NakamaClient setget _set_readonly_variable, get_nakama_client
var nakama_session: NakamaSession setget set_nakama_session
var nakama_socket: NakamaSocket setget _set_readonly_variable

# Internal variable for initializing the socket.
var _nakama_socket_connecting := false

signal session_changed (nakama_session)
signal session_connected (nakama_session)
signal socket_connected (nakama_socket)

var nodes: Array

func _ready() -> void:
	# Don't stop processing messages from Nakama when the game is paused.
	Nakama.pause_mode = Node.PAUSE_MODE_PROCESS
	$Timer.wait_time = 1.0/TICK_RATE

func _set_readonly_variable(_value) -> void:
	pass

func get_nakama_client() -> NakamaClient:
	if nakama_client == null:
		nakama_client = Nakama.create_client(
			nakama_server_key,
			nakama_host,
			nakama_port,
			nakama_scheme,
			Nakama.DEFAULT_TIMEOUT,
			NakamaLogger.LOG_LEVEL.ERROR)
	
	return nakama_client

func set_nakama_session(_nakama_session: NakamaSession) -> void:
	# Close out the old socket.
	if nakama_socket:
		nakama_socket.close()
		nakama_socket = null
	
	nakama_session = _nakama_session
	
	emit_signal("session_changed", nakama_session)
	
	if nakama_session and not nakama_session.is_exception() and not nakama_session.is_expired():
		emit_signal("session_connected", nakama_session)

func connect_nakama_socket() -> void:
	if nakama_socket != null:
		return
	if _nakama_socket_connecting:
		return
	_nakama_socket_connecting = true
	
	var new_socket = Nakama.create_socket_from(nakama_client)
	yield(new_socket.connect_async(nakama_session), "completed")
	nakama_socket = new_socket
	_nakama_socket_connecting = false
	
	emit_signal("socket_connected", nakama_socket)

func is_nakama_socket_connected() -> bool:
	   return nakama_socket != null && nakama_socket.is_connected_to_host()
	

func start():
	$Timer.start()

func _on_Timer_timeout() -> void:
	get_tree().call_group("networked", "_network_process", 1.0/TICK_RATE)
