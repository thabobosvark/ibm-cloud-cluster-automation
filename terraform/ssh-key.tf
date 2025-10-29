# Create a new SSH key for GitHub Actions
resource "ibm_is_ssh_key" "github_actions_key" {
  name       = "github-actions-key-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  public_key = file("${path.module}/github_actions_key.pub")
}
