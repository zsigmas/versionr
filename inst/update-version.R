tryCatch(
  expr = {
    if(!require(versionr)){
      stop('Version not updated, versionr not found')
    }else{
      print(paste('From:', versionr::current_version(), 'to', clean_version_number(versionr::get_describe_head())))
      print(paste('Branch:', versionr::get_branch_name()))
      print(paste('Commit:', versionr::get_commit_id()))
      versionr::update_version()
    }
  },
  error = function(e){
    print(e)
    quit(status=1)
  }
)


