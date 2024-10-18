variable "project" {
    description = "project name"
    default = "sist-cont-app"
}

variable "tags" {
    description = "tags used in this project"
    default = {
        env: "dev",
        creator: "terraform",
        project: "sist-cont-app"
    }
}

variable "enviroment" {
    description = "enviroment to release"
    default = "dev"
}

variable "location" {
    description = "Azure region"
    default = "East US 2"
}

variable "sql-password" {
    description = "azure sql-server password"
    type = string
    sensitive = true
}

variable "sql-user" {
    description = "azure sql-server user"
    type = string
}

variable "subscription_id" {
    description = "Azure subscription id for this project"
    type = string
}