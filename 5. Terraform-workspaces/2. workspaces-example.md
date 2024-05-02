**Terraform workspaces uses:**

- below are the terraform workspaces command. we can get those command with the help of the ```terraform workspace -h```

```
[root@ip-172-31-17-17 terraform]# terraform workspace -h
Usage: terraform [global options] workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
[root@ip-172-31-17-17 terraform]# 

```

- with the help of the above command we can create, switch, show the workspaces.

- create the main.tf file and then create the workspace and switch into it.
- once we execute the terafom apply command after switching it into env, then state file will create in that perticular workspace
- you can use below hierarchy as a refernece.

```
  [root@ip-172-31-17-17 terraform]# tree
.
├── main.tf
├── modules
│   └── ec2_instance
│       ├── main.tf
│       └── variables.tf
├── terraform.tfstate.d
│   ├── dev
│   └── stg
├── terraform.tfvars
└── variables.tf

5 directories, 5 files
```
