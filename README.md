Extend Cron
==========================
Extend cron (e-cron) is a framework of Linux/Unix cron batch management.
It can provide single CLI batch management console for several endpoint's cron job.
Functions are as following.

1. Command Line Interface,
   You can distribute same batch file to each endpoints and can watch the results at console server.
   
2. Error handling of cron bach job,
   you can define next action based on the result of job execution.
   
3. Define job order and relation ship between endpoints, 
   e-cron can send message to end point to start job when it meet requirements 
   (Execute job based on schedule and other endpoint's job results that define relationship)
   
4. Basic monitoring (CPU/Memory/Log) 

e-cron is written by light scripts and works quickly with basic unix commands.
So it will be recommended to use this framework to Linux base IoT endpoints management as well.
See detail at http://www.e-cron.org
