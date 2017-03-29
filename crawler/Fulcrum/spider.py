import scrapy

class BlogSpider(scrapy.Spider):
    name = 'gitlabspider'
    start_urls = ['http://fulcrum-jwyoung.c9users.io:8080/users/sign_in']
    def parse(self, response):
        yield scrapy.FormRequest(
            response,
            formdata={
                'user[email]': 'test@example.com',             
                'user[password]': 'testpass',   
                'Action':'1',
            },
            callback=self.access
        )
  
    def access(self,response):
        next_page = response.css('a ::attr(href)').extract_first()
        print 'next_page', response.urljoin(next_page)
        if next_page and next_page.startswith('http://fulcrum-jwyoung.c9users.io'):
            yield scrapy.Request(response.urljoin(next_page), callback=self.parse)
        
    
