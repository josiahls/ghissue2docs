# ghissue2docs
> Converting github issues into local markdown files or notebooks for integrating into documentation.


## Install
Just run `pip install ghissue2docs`!

## How to Simple

```python
from ghissue2docs.core import *
from fastcore.all import *
```

Run the `gh auth login` command. to get access to your project.

Then get all the documentation tagged issues...

```python
got_issues=get_issues('documentation');got_issues
```




    [{'assignees': [],
      'author': {'login': 'josiahls'},
      'body': 'This is an example documentation issue\r\n\r\nBelow is a picture!\r\n![image](https://user-images.githubusercontent.com/19930483/146814046-fc69bf3f-bc6a-41d4-9971-146b5884ee55.png)\r\n',
      'id': 'I_kwDOGj3YrM5ArPed',
      'title': 'Examples.Test Documentation Issue!',
      'url': 'https://github.com/josiahls/ghissue2docs/issues/1'}]



Ok! So we have a list of issues, now we can make a simple loop to (for example) display 
all the issues in the jekyll server (via nbdev)!

```python
for issue in got_issues:
    out=issue2txt(issue)
    issue2ipynb(*out,Path('.'))
```
