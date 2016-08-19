from common.methods import set_progress

def run(job, logger=None, **kwargs):
	
    #Connect To The Server Via SSH And Run Chef Decommission Recipe
    cmd = '[ -f /etc/chef/client.pem ] && chef-client -o server-destroy || echo Chef Run Did Not Occur'
    params = job.job_parameters.cast()
    server = params.servers.first()
    server.key_name = '../svrbuild_id_rsa'
    server.save()
    try:
        output = server.execute_script(script_contents=cmd, runas_username='svrbuild', run_with_sudo=True, timeout=600)
        logger.debug(output)
        set_progress("Chef Decommission Complete")
    except Exception as ex:
        template = "An exception of type {0} occured. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        if type(ex).__name__ in ['CommandExecutionException', 'ValueError']:
            if type(ex).__name__ == 'CommandExecutionException':
                logger.debug(ex.output)
            set_progress("Failed to Run Chef client destroy")
        else:
            set_progress(message)
            return "FAILURE", "Server failed during Decommission", ""
    server.save()
    return "SUCCESS", "Server Has Been Successfully Decommissioned!", ""
