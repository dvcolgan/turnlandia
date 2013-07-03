from webdriverplus import WebDriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from django.conf import settings
from django.test import LiveServerTestCase
from django.core.urlresolvers import reverse

import time
import ipdb



class TestEverything(LiveServerTestCase):
    fixtures = ['library/fixtures/test-data.json']
    article_urls = [
        'http://www.springwise.com/financial_services/young-prospects-solicit-advice-connections-funding-successful-entrepreneurs-site/',
        'http://www.wildwestcycle.com/f_pensees.htm',
        'http://www.telegraph.co.uk/news/worldnews/europe/vaticancityandholysee/9760782/Pope-says-future-of-mankind-at-stake-over-gay-marriage.html',
        'http://ryanstreeter.com/2012/11/30/costco-dividend-comedy/',
        'http://ryanstreeter.com/2012/11/02/kenworthy-family-background-drives-equality-of-opportunity-more-than-race-or-gender-these-days/',
        'http://www.washingtonpost.com/opinions/michael-gerson-the-trouble-with-obamas-silver-lining/2012/11/05/6b1058fe-276d-11e2-b2a0-ae18d6159439_story.html',
        'http://www.economist.com/news/united-states/21565976-real-blow-republicans-may-be-not-they-failed-take-white-house?fb_action_ids=4992925786932&fb_action_types=og.likes&fb_ref=scn%2Ffb_ec%2Fstate_of_denial&fb_source=other_multiline&action_object_map=%7B%224992925786932%22%3A449788485058092%7D&action_type_map=%7B%224992925786932%22%3A%22og.likes%22%7D&action_ref_map=%7B%224992925786932%22%3A%22scn%5C%2Ffb_ec%5C%2Fstate_of_denial%22%7D',
        'http://techcrunch.com/2012/11/10/an-entrepreneurs-guide-to-patents-the-basics/',
        'http://www.nytimes.com/2012/11/19/opinion/krugman-the-twinkie-manifesto.html?ref=opinion&_r=0',
        'http://townhall.com/columnists/tabithahale/2012/11/09/dc_cannot_save_america_hollywood_can/page/full/',
        'http://techcrunch.com/2012/11/24/an-entrepreneurs-guide-to-patents-are-patents-right-for-your-company/',
        'http://www.nytimes.com/2012/11/20/opinion/brooks-the-conservative-future.html?smid=fb-share&_r=0',
        'http://online.wsj.com/article/SB10001424127887324352004578133513311164782.html',
        'http://www.theimaginativeconservative.org/ten-conservative-principles/#.UT0_sHHS9FQ',
        'http://www.nytimes.com/2012/09/25/opinion/brooks-the-conservative-mind.html',
        'http://www.indystar.com/article/20121213/NEWS05/212130347/Poll-Hoosiers-against-constitutional-ban-gay-marriage?nclick_check=1',
        'http://blogs.hbr.org/cs/2012/12/if_youre_serious_about_ideas_g.html#conferam-bookmarklet-save-modal',
        'http://www.detroitnews.com/article/20130123/BIZ/301230391/Union-membership-falls-70-year-low?odyssey=tab%7Ctopnews%7Ctext%7CFRONTPAGE',
        'http://www.linkedin.com/today/post/article/20130124004024-1131485-having-a-point-of-view',
        'http://www.hillsdale.edu/news/imprimis/archive/issue.asp?year=2012&month=12',
        'http://www.christianitytoday.com/ct/2013/january-february/my-train-wreck-conversion.html?start=1',
        'http://live.washingtonpost.com/brad-hirschfield-021913.html',
        'http://www.itsabouttv.com/2013/02/ayn-rand-on-tonight-show-1967.html',
        'http://www.linkedin.com/today/post/article/20130303182619-6388496-here-s-your-comment-or-don-t-blame-the-internet',
        'http://www.nytimes.com/2013/03/03/opinion/sunday/this-story-stinks.html?hp&_r=3&',
    ]
    
    @classmethod
    def setUpClass(cls):
        settings.DEBUG = True
        cls.selenium = WebDriver('chrome', wait=10)
        super(TestEverything, cls).setUpClass()

    @classmethod
    def tearDownClass(cls):
        cls.selenium.quit()
        super(TestEverything, cls).tearDownClass()

    def setUp(self):
        settings.SITE_DOMAIN = self.live_server_url

    def start_bookmarklet(self):
        self.selenium.execute_script("""
            javascript:(function() {
            if (typeof window.CONFERAM === 'undefined') {
                var s=document.createElement('script');
                s.type='text/javascript';
                s.src='""" + self.live_server_url + reverse('library.views.bookmarklet_src') + """';
                document.body.appendChild(s);
            }else{window.CONFERAM.bookmarklet.restart();}})();
        """)

    def login(self):
        self.selenium.get(self.live_server_url + reverse('login'))
        self.selenium.find('input', name='username').click().send_keys('dvcolgan@gmail.com')
        self.selenium.find('input', name='password').click().send_keys('password')
        self.selenium.find('input', type='submit').click()

    def test_invite_code(self):
        self.login()

        # Create the code using the admin account
        self.selenium.get(self.live_server_url + '/admin/')
        self.selenium.find(link_text='Invites').click()
        self.selenium.find(link_text='Add invite').click()
        self.selenium.find('#id_description').click().send_keys('Test Invite')
        self.selenium.find('#id_max_uses').click().send_keys('2')
        invite_code = self.selenium.find('#id_code').value
        self.selenium.find('input', name='_save').click()

        # Log out and use the code to create another account
        self.selenium.get(reverse('logout'))
        self.selenium.get(self.live_server_url + reverse('signup', args=(invite_code,)))

        self.selenium.find('#id_email').click().send_keys('andrewneel@gmail.com')
        self.selenium.find('#id_first_name').click().send_keys('Andrew')
        self.selenium.find('#id_last_name').click().send_keys('Neel')
        self.selenium.find('#id_password1').click().send_keys('password')
        self.selenium.find('#id_password2').click().send_keys('password')
        self.selenium.find('input', type='submit').click()

        # Make sure we get to the bookmarklet install page
        self.selenium.find('h2', text='Install the Conferam Bookmarklet')

    def test_install_bookmarklet(self):
        self.login()
        self.selenium.find('#nav-gears').click()
        self.selenium.find(link_text='Install Bookmarklet').click()
        bookmarklet_src = self.selenium.find('#bookmarklet-installer-button').attributes['href']

        self.selenium.get(TestEverything.article_urls[0])
        self.selenium.execute_script(bookmarklet_src)
        self.selenium.find('#conferam-bookmarklet-container')
        
    



    def test_bookmarklet_load(self):
        self.login()
        for url in TestEverything.article_urls:
            print url
            self.selenium.get(url)
            self.start_bookmarklet()
            container = self.selenium.find('div#conferam-bookmarklet-container')

            textual_p_tags = [p for p in self.selenium.find('p') if len(p.text) > 100][:3]
            p_tag = textual_p_tags[0]


            chain = ActionChains(self.selenium)
            chain.move_to_element(p_tag)
            chain.click_and_hold()
            chain.move_by_offset(10, 50)
            chain.release()

            print 'performed'


            time.sleep(1)
            print 'done waiting'

            #self.assertTrue(len(self.selenium.find('.conferam-bookmarklet-highlight')) > 0, 'Failed to highlight')

    def test_massage_bookmarklet(self):
        self.login()
        self.selenium.get(TestEverything.article_urls[0])
        self.start_bookmarklet()
        container = self.selenium.find('div#conferam-bookmarklet-container')

        textual_p_tags = [p for p in self.selenium.find('p') if len(p.text) > 100][:3]
        p_tag = textual_p_tags[0]
        chain = ActionChains(self.selenium)

        chain.move_to_element(p_tag).click_and_hold().move_by_offset(80, 10).release()


        time.sleep(1)

        #self.assertTrue(len(self.selenium.find('.conferam-bookmarklet-highlight')) > 0, 'Failed to highlight')

    def test_add_category_in_library(self):
        self.login()
        self.selenium.find(link_text='Add New Category').click()
        self.selenium.find('input', name='name').click().send_keys('Test Category')
        self.selenium.find('input', type='submit').click()

        



    # This should do more things, like test for edge cases like wrong password.
    def test_login(self):
        self.login()


    def test_start_discussion(self):
        # Get to the category page
        self.login()
        self.selenium.find(link_text='Test Category').click()

        # Exercise the expanding and contracting
        self.selenium.find(class_name='icon-chevron-down').click()
        time.sleep(0.5)
        self.selenium.find(class_name='icon-chevron-down').click()
        time.sleep(0.5)

        # Start the discussion
        self.selenium.find(link_text='Discuss')[0].click()
        self.selenium.find('input', name='statement').click().send_keys('I believe that this test will succeed.')
        self.selenium.find('textarea', name='comment').click().send_keys('If this test works, that means that the site is working.  I would like to see that happen.')
        highlight_container = self.selenium.find(class_name='discussion-highlights-container')
        highlight_container.find('a')[0].click()
        highlight_container.find('a')[1].click()
        highlight_container.find('a')[3].click()
        typeahead = self.selenium.find('#discussion-participants-typeahead').click()
        typeahead.send_keys('a')
        time.sleep(0.6)
        typeahead.send_keys('n')
        time.sleep(0.6)
        typeahead.send_keys('d')
        time.sleep(0.6)
        typeahead.send_keys(Keys.ENTER)
        typeahead = self.selenium.find('#discussion-participants-typeahead').click()
        typeahead.send_keys('a')
        time.sleep(0.6)
        typeahead.send_keys('u')
        time.sleep(0.6)
        typeahead.send_keys('s')
        time.sleep(0.6)
        typeahead.send_keys(Keys.ENTER)
        self.selenium.find('#privacy-everyone').click()
        self.selenium.find('input', type='submit').click()
        self.selenium.find(class_name='discussion-headline', text='I believe that this test will succeed.')
        self.selenium.find(class_name='icon-chevron-down').click()
        time.sleep(1)

        
        
    #def test_use_bookmarklet(self):
    #    self.login()
    #    self.selenium.get('http://www.cnn.com/2013/03/06/world/americas/venezuela-chavez-main/index.html?hpt=hp_inthenews')
    #    self.start_bookmarklet()

    #    self.selenium.execute_script("window.scrollTo(0, 500);")
    #    chain = ActionChains(self.selenium)
    #    p_tag = self.selenium.find(class_name='cnn_storypgraph2')
    #    chain.click_and_hold(p_tag)
    #    chain.click_and_hold(p_tag)
    #    chain.move_by_offset(100, 20)
    #    chain.release(p_tag)
    #    chain.perform()

        



