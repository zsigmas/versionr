update_version <- function(path='.', print_output=F) {
  con <- file('DESCRIPTION')
  on.exit(close(con))

  desc_content <- readLines(con)
  version_idx  <- which(startsWith(desc_content, 'Version:'))
  date_idx  <- which(startsWith(desc_content, 'Date:'))
  branch_idx  <- which(startsWith(desc_content, 'Branch:'))
  commit_idx <- which(startsWith(desc_content, 'ParentCommit:'))
  desc_content[version_idx] <- paste('Version:', clean_version_number(get_describe_head()))

  if(length(date_idx)==0){date_idx=length(desc_content)+1}
  desc_content[date_idx] <- paste('Date:', date())

  if(length(branch_idx)==0){branch_idx=length(desc_content)+1}
  desc_content[branch_idx] <- paste('Branch:', get_branch_name())

  if(length(commit_idx)==0){commit_idx=length(desc_content)+1}
  desc_content[commit_idx] <- paste('ParentCommit:', get_parent_commit_id())

  writeLines(desc_content, con = con)
  if(print_output){return(desc_content)}
}

current_version <- function(path='.') {
  con <- file('DESCRIPTION')#
  on.exit(close(con))

  desc_content <- readLines(con)
  version_idx  <- which(startsWith(desc_content, 'Version:'))
  current_version <- unlist(strsplit(desc_content[version_idx], split=': ', fixed = T))[2]
  return(current_version)
}

get_describe_head <- function() {
  if(!dir.exists('.git')){stop("Can't find .git directory in specified path")}
  system2(command="git", args="describe HEAD --tags | rev | sed 's/g-/./' | sed 's/-/+/' | rev", stdout=T)
}

get_branch_name <- function() {
  if(!dir.exists('.git')){stop("Can't find .git directory in specified path")}
  system2(command="git", args="rev-parse --abbrev-ref HEAD", stdout=T)
}

get_parent_commit_id <- function(){
  if(!dir.exists('.git')){stop("Can't find .git directory in specified path")}
  system2(command="git", args="rev-parse HEAD", stdout=T)
}

clean_version_number <- function(ver_num) {
  spl_ver_num <- unlist(strsplit(ver_num, split='+', fixed = T))
  ver_num <- spl_ver_num[1]
  commit_num <- unlist(strsplit(spl_ver_num[2], split='.', fixed = T))[1]
  commit_num <- ifelse(!is.na(commit_num),paste0('-', commit_num), '')
  return(paste0(ver_num, commit_num))
}

init <- function(path='.', .force_update_copy=F) {

  origin_pre_commit_file <- system.file('pre-commit', package='versionr', mustWork = T)
  origin_update_version_file <- system.file('update-version.R', package='versionr', mustWork = T)

  target_pre_commit_file <- file.path(path, '.git', 'hooks', 'pre-commit')
  target_update_version_file <- file.path(path, '.git', 'hooks', 'update-version.R')

  if(file.exists(target_pre_commit_file)){
    cat(paste0('File pre-commit already exists, paste the block below in the pre-commit file\n\n',
               paste0(readLines(origin_pre_commit_file), collapse='\n'),
               '\n')
        )

  }else{
    print(paste('Copying Origin:', origin_pre_commit_file, '->', 'Target:', target_pre_commit_file))
    file.copy(origin_pre_commit_file, target_pre_commit_file)
  }

  if(!file.exists(target_update_version_file) | .force_update_copy){
    print(paste('Copying Origin:', origin_update_version_file, '->', 'Target:', target_update_version_file))
    file.copy(origin_update_version_file, target_update_version_file, overwrite = T)
  }else{
      warning('Update version file is already present, use .force_update_copy if you want it copied')
  }

}
