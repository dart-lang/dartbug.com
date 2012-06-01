import logging
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

LIST_URL = 'http://code.google.com/p/dart/issues/list'
NEW_URL = 'http://code.google.com/p/dart/issues/entry'
SHOW_URL = 'http://code.google.com/p/dart/issues/detail?id='
USER_ME_URL = 'http://code.google.com/p/dart/issues/list?can=2&q=owner%3Ame'
USER_URL = 'http://code.google.com/p/dart/issues/list?can=2&q=owner%3A'

class ListIssues(webapp.RequestHandler):
  def get(self):
    self.redirect(LIST_URL)
    
class NewIssue(webapp.RequestHandler):
  def get(self):
    self.redirect(NEW_URL)
    
class ShowIssue(webapp.RequestHandler):
  def get(self, issue_id):
    try:
      issue_num = int(issue_id) # validation
      self.redirect(SHOW_URL + str(issue_num))
    except:
      self.redirect(NEW_URL)

class UserMeIssue(webapp.RequestHandler):
  def get(self, issue_id):
    self.redirect(USER_ME_URL)

class UserNameIssue(webapp.RequestHandler):
  def get(self, username):
    self.redirect(USER_ME_URL + username + '%40google.com')

application = webapp.WSGIApplication([(r'/([0-9]+)', ShowIssue),
                                      ('/new', NewIssue),
                                      ('/me', UserMeIssue),
                                      (r'/([a-zA-Z]+)', UserNameIssue),
                                      ('/', ListIssues)],
                                     debug=True)

def main():
  run_wsgi_app(application)

if __name__ == '__main__':
  main()