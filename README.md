# repository-milestone-changer

## Table of Contents

* [About the Project](#about-the-project)
* [Prerequisites](#prerequisites)
* [Try out the project](#try-out-the-project)
* [Contributing](#contributing)
* [License](#license)

## About the project

API service which uses the GitHub API service to change the milestone of a set of issues at once. This was developed in order to elimate the process of manually updating the milestones one by one. _A total of 100 issues_ can be **modified at a time**.

## Prerequisites

You should have installed:
- Ballerina or you can download and install it through https://ballerina.io/learn/installing-ballerina/.

## Try out the project

- Clone the repository to a place of your preference using the command `git clone https://github.com/deshankoswatte/repository-milestone-changer.git`.
- Open the cloned repository folder.
- Run the program using the command using `milestone_changer_activate.sh` on the root folder.
- Provide the values for: _Organization Name_, _Repository Name_, _Milestone Name to be changed_, _Milestone Name to be changed to_ and _Your Access Token_ to the html form fields and click 'submit'.

## Contributing

Contributions make the open source community such an amazing place to learn, inspire, and create. Any contribution you make to this project is **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/NewFeature`)
3. Commit your Changes (`git commit -m 'Add some NewFeature'`)
4. Push to the Branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

## License

Distributed under the Apache License 2.0. See `LICENSE` for more information.
