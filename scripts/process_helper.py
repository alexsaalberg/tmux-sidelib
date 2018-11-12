
def get_program_from_pid(pid):
	program_as_bytes = check_output(['ps', '-p '+pid, '-o comm='])
	program_as_str = program_as_bytes.decode()
	return program_as_str[:-1] #get rid of /n

def get_clean_program(prog):
	if prog == '-bash':
		return 'bash'
	return prog
	
def get_leaf_pid(root_pid):
	try:
		child_pid_bytes = check_output(['pgrep', '-P', root_pid])
		child_pid = child_pid_bytes[:-1].decode() #[:-1]: get ride of \n
		return get_leaf_pid(child_pid)
	except CalledProcessError:
		return root_pid