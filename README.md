= Design Pattern Quiz
Application for Design Patterns

== General overview

This documentation was design for the Final Project for the 
<em>Software Design and Architecture</em> course (_Tc3049_)
in which its intended goal was to develop a web application
for a quiz on Design Patterns and Antipatterns using microservices,
<tt>Ruby</tt> and the DSL <tt>Sinatra</tt>.

The directory structure for the application and its documentation is as follows:

    Design_Pattern_Quiz/
        doc/                        Folder produced by RDoc.
        img/                        Folder for the documentation's image files.
        src/                        Folder for the application's source code.
            public/                Folder for the server's public documents.
                images/      Folder for the application's images.
            models/                Folder for the application's models.
            views/                 Folder for the application's views (ERB files).
            functions/             Folder for the application's microservices functions.


== How to install and run the application and all the microservices

You need to have Ruby 2.3 or more recent and the {Sinatra}[http://www.sinatrarb.com/] gem installed in your system to run the _Design Pattern Quiz_ web application. To run the server type the following command at the terminal from the +Design_Pattern_Quiz/src+ directory:

    $ ruby -I . -w index.rb

Afterwards, point your web browser the server's root URL.

== 4+1 architectural view model

=== Logical view

rdoc-image:img/logical_view.png

=== Process view

rdoc-image:img/process_view.png

=== Development view

rdoc-image:img/development_view.png

=== Physical view

rdoc-image:img/physical_view.png

=== Scenarios

rdoc-image:img/scenarios.png

== Patterns used

- <b>Domain-Specific Language</b>: The +index.rb+ file consists of a series of Sinatra _routes_. Sinatra is a DSL for creating web applications in Ruby.
- <b>Model-View-Controller</b>: The application follows the classical web implementation of the MVC architectural pattern. The models (+.rb+ files) and views (+.erb+ files) are stored in the corresponding +models+ and +views+ directory. The controller is contained in +index.rb+ file.
- <b>Singleton Pattern</b>: The +index.rb+ file calls for a single instance of the +microservices.rb+ file which itself includes the +Singleton+ module.

== Authors

* *A01378840* <em>Marco Antonio Ríos Gutiérrez</em>
* *A01378840* <em>Marco Antonio Rios Gutierrez</em>
* *A01371719* <em>Servio Tulio Reyes Castillo</em>

== Acknowledgments

Professor Ariel Ortiz Ramirez

== References

- \E. Gamma, R. Helm, R. Johnson, J. M. Vlissides. <em>Design Patterns: Elements of Reusable Object-Oriented Software.</em> Addison-Wesley, 1994.

- \A. Harris, K. Haase. <em>Sinatra: Up and Running.</em> Oâ€™Reilly, 2011.

- \Ph. Kruchten. <em>The 4+1 View Model of Architecture.</em> IEEE Software, vol. 12 (6), pp. 45-50, 1995. {\http://www.ics.uci.edu/~andre/ics223w2006/kruchten3.pdf}[http://www.ics.uci.edu/~andre/ics223w2006/kruchten3.pdf] Accessed April 11, 2019.

- \R. Olsen. <em>Design Patterns in Ruby.</em> Addison-Wesley, 2007.

- Source Making. <em>Design Antipatterns Reference.</em> {\https://sourcemaking.com/antipatterns/}[https://sourcemaking.com/antipatterns/] Accessed November 26, 2019.
