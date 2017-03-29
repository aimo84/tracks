import scrapy
import MySQLdb
from scrapy import Selector
output = open('output4.txt','w')
users = {} 

class BlogSpider(scrapy.Spider):
    name = 'gitlabspider'
    start_urls = ['https://gitlab.com/users/sign_in']
    def parse(self, response):
        yield scrapy.FormRequest.from_response(
            response,
            formdata={
                'user[login]': 'junwen@uchicago.edu',             
                'user[password]': 'abcdabcd',             
                'Action':'1',
            },
            callback=self.after_login
        )
    def after_login(self, response):
        baseurl = 'https://gitlab.com/explore/projects?page='
        #Specify pages to crawl here:
       
        for i in range(1, 12654):
            yield scrapy.Request(url= baseurl + str(i),
            callback=self.parseAfterLogin)
        
        #db.close()
        
    def parseAfterLogin(self, response):
        for project in response.css('div.title'):
            next_page = project.css('a ::attr(href)').extract_first()
            # go to the project link
            detail = response.urljoin(next_page)
            #print detail
            request = scrapy.Request(detail, callback = self.parseProject)
            yield request
            
    def parseProject(self, response):
        title = response.css('h3.page-title ::text').extract_first()
        project_title = response.css('h1.project-title ::text').extract_first()
        user = response.css('a.project-item-select-holder').css('a ::attr(href)').extract_first()
        print user
        user_arr = user.split('/')
        # username projectname
        username = user_arr[1]
        projectname = user_arr[2]
        print username, projectname
        project_arr = []
        if(username in users.keys()):
            project_arr = users[username]
        commit = 0
        branch = 0
        tags = 0
        issues = '0'
        merge_requests = '0'
        if(project_title):
            # issues and merge_requests
            iss_class = "badge count issue_counter"
            issues = response.selector.xpath('//span[@class=iss_class]/text()').extract()
            if issues:
                issues = int(issues.replace(',',''))
            else:
                issues = 0
            mer_class = "badge count merge_counter"
            merge_requests = response.selector.xpath('//span[@class=mer_class]/text()').extract()
            if merge_requests :
                merge_requests = int(merge_requests.replace(',',''))
            else:
                merge_requests = 0
            if(title == '\nThe repository for this project is empty\n'):
                print 'empty'
            else:
                for prop in response.css('ul.nav > li'):
                    p = prop.css('a ::text').extract_first()
                    # print p
                    # replace the () and \n in the original data
                    p = p.replace('(','')
                    p = p.replace(')', '')
                    p = p.replace('\n', '')
                    p = p.replace(',', '')
                    # print p
                    # split the string by space 
                    new_str = p.split(' ')
                    ## only get the info about #commit, #branch, #tags
                    if( len(new_str) == 2):
                        if(new_str[0] == 'Commits' or new_str[0] == 'Commit'):
                            commit = int(new_str[1])
                        
                        if(new_str[0] == 'Branch' or new_str[0] == 'Branches'):
                            branch = int(new_str[1])
                            
                        if(new_str[0] == 'Tags' or new_str[0] == 'Tag'):
                            tags =  int(new_str[1])
                        
                        
                        #print commit, branch, tags
                
        else:
            print 'invalid project'
        final_pro = [username, projectname, commit, branch, tags]
        # ouput it to file
        output.write(username+ " " + projectname + " " +  str(commit) + " " + str( branch )+ " " + str(tags) +" " + str(issues) +" " + str(merge_requests) + '\n')
        #project_arr.append(final_pro)
    