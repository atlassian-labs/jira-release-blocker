## Releasing a new version

This pipe uses an automated release process to bump versions using semantic versioning and generate the CHANGELOG.md file automatically. 

In order to automate this process it uses a tool called [`semversioner`](https://pypi.org/project/semversioner/). 

### Steps to release

1) Install semversioner in local.

```sh
pip install semversioner
```

2) During development phase, every change that needs to be integrated to `master` will need one or more changeset files. You can use semversioner to generate changeset.

```sh
semversioner add-change --type patch --description "Fix security vulnerability with authentication."
```

3) Make sure you commit the changeset files generated in `.change/next-release/` folder with your code. For example:

```sh
git add .
git commit -m "BP-234 FIX security issue with authentication"
git push origin 
```

4) That's it! Merge to `master` and Enjoy! Bitbucket Pipelines will do the rest:

- Generate new version number based on the changeset types `major`, `minor`, `patch`.
- Generate a new file in `.changes` directory with all the changes for this specific version.
- (Re)generate the CHANGELOG.md file.
- Bump the version number in `README.md` example and `pipe.yml` metadata.
- Commit and push back to the repository.
- Tag your commit with the new version number.