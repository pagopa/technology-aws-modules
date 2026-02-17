output "repository_urls" {
  value = {
    for repository_key, repository in module.repository :
    repository_key => repository.repository_url
  }
}

output "repository_names" {
  value = {
    for repository_key, repository in module.repository :
    repository_key => repository.repository_name
  }
}
