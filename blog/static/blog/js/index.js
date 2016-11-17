/*golobal $, alert, console*/
   	var wh   = $(window),
        main = $('.main'),
        nav  = $('.navbar'),
        nv   = $("nav"),
        bg   = $('.background'),
        header = $('header');
    
$(function(){
    'use strict';
   header.height($(window).height());
   
   $(window).resize(function(){
    header.height($(window).height());
   });
       $(main).css(
        "top", (wh.height() - main.height() ) / 2 

        );
        $(main).css(
        "left", (wh.width()- main.width() ) / 2
        );
         $(window).resize(function(){
           $(main).css(
        "top", (wh.height() - main.height() ) / 2 

        );
        $(main).css(
        "left", (wh.width()- main.width() ) / 2
        );
   });

        bg.height($(window).height());
        
        $(window).resize(function(){
        bg.height($(window).height());
   });
                 
         $("ul li").mouseenter(function(){
            $(this).animate({
                opacity: .5,
            },1000);
        });
        $("ul li").mouseover(function(){
            $(this).animate({
                opacity: 1,
            });
        });

        $('a').click(function(){
        $('a').removeClass('active');
        $(this).addClass('active');
        });
        
        new WOW().init();
        smoothScroll.init({
                speed: 1000, 
                easing: 'easeOutQuad',
                updateURL: false,
            });
        
        $('.workbtn').click(function(){
           $('.item').fadeIn(2000).removeClass('hidden');
        });
        
        wh.scroll(function(){
            $(this).scrollTop();
            if ($(this).scrollTop() > 990 )
            {
            $('.timer').countTo();
            }
            });
    

        $("html").niceScroll({
            cursorwidth: "10px",
            cursorborder: "0px solid #fff",
            cursorborderradius: "0",
            
            });
        
        $(".hum").click(function(){
           nv.slideToggle(); 
        }); 
            
        $(".menu li").click(function(){
                if (matchMedia('only screen and (max-width : 768px)').matches) {
                nv.slideToggle();
            }
            
        });
        
        $(window).scroll(function(){
            $(this).scrollTop();
            if ($(this).scrollTop() >= 80)
            {
            nav.addClass("fixed");
            }else
            nav.removeClass("fixed");
            if (matchMedia('only screen and (max-width : 768px)').matches) {
            nav.removeClass("fixed");
            }
            });
        
});
