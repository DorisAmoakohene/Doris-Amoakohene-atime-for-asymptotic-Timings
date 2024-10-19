
Performance analysis is a fundamental component of software development, particularly when it comes to the design and implementation of algorithms. 
% Efficient algorithms not only improve execution times but also reduce resource consumption, making systems more scalable and reliable. \cite{knuth1997art}, in his seminal work, emphasized the critical role that understanding algorithmic performance plays in building robust and efficient software. 
% TDH 19 Sept 2024 citation not relevant.
This importance is even more pronounced for developers working in environments like R, where large data manipulation and statistical analysis are common, and the performance of code directly impacts the size of data sets that can be handled on a given computer.

\paragraph{Performance testing.}

Performance tests aim to assess a package repository for available version releases and benchmark its performance, including gathering information on memory usage and execution time, of this version release.
for example in memory usage, the test is to evaluates the memory used by a package during execution. For instance, using tools like \pkg{memory\_profiler} \citet{memory_profiler} in Python, one can track how much memory is consumed at various points in the code. Measuring execution time, involves the time taken for specific functions or processes takes to complete. For example, employing the \pkg{timeit} \citet{timeit} module in Python allows users to run a piece of code multiple times and calculate the average execution time.

\paragraph{Comparative benchmarking.}

In Comparative benchmarking, we compare and visualize the asymptotic performance (time and memory usage) of the different functions, By comparing the asymptotic performance of these functions in various or particular programming languages, with the aim of provide insights into their usage and to help data scientists make informed choices when it comes to data
manipulation and analysis. In R \pkg{profvis} \citet{profvis} is used can be used for memory measurement and microbenchmark \citet{microbenchmark} for time measurement.

For R package developers, performance testing holds several essential benefits. 
% The concept presented here aligns with the principles outlined in \citet{performance2021}, which emphasizes the importance of identifying performance bottlenecks to optimize execution times and enhance overall user experience. 
% TDH 19 Sept 2024 This citation does not make sense, performance package is not about time/memory measurement.
Performance testing ensures scalability, helping developers understand how well a package can handle increasing data sizes.
% and complexity, a particularly important aspect as datasets continue to grow in size and complexity. 
% again, performance testing under a variety of stress conditions to test the reliability of the package, ensuring that it performs robustly across different scenarios. 
Finally, documented performance metrics boost user confidence, helping them to select the packages for their projects, knowing that the tools they rely on have been rigorously tested and benchmarked.

Despite the availability of tools for performance testing and benchmarking in languages like R and Python, existing solutions are often limited in scope. 
\citet{pytest_benchmark} developed pytest-benchmark which integrates airspeed velocity benchmarking into pytest, allowing users to easily measure and compare the performance of their code.

% For more information, you can refer to my useR presentation \href{https://www.youtube.com/watch?v=AuuGzUSSjpI}{here}. 
% TDH 19 sept 2024 it is not appropriate to include "here" style links in formal research papers.
%In \citet{sedgewick2013algorithms} book on Introduction to the Analysis of Algorithms the need for more flexible tools is especially important when evaluating not only raw performance metrics but also the asymptotic behavior of algorithms, which is crucial for understanding how they will perform as the complexity of inputs increases over time.

The need for more flexible tools is especially important when evaluating not only raw performance metrics but also the asymptotic behavior of algorithms, which is crucial for understanding how they will perform as the complexity of inputs increases over time.

Another important aspect of performance testing is regression detection. As developers continue to evolve their code, new versions of packages may unintentionally introduce bugs or inefficiencies. This makes continuous testing and verification critical, particularly in open-source software development environments where the code is constantly being updated and improved. According to %\citet{githubactions2024} tools like GitHub Actions have streamlined this process by allowing developers to automate the detection of performance regressions (TODO CLARIFY).
By automating workflows, developers can continuously track and address performance issues, ensuring that new changes do not compromise the quality or efficiency of their software.

Popular packages like bench \citet{bench} and microbenchmark\citet{microbenchmark} in R, and timeit \citet{timeit} and pytest\_benchmark \citet{pytest_benchmark} in Python, have provided developers with means to compare code execution times and identify potential performance issues, but usually only support single values of N (the input size). Many benchmarking packages only support testing with fixed input sizes, rather than evaluating asymptotic performance as data size increases.

Some tools like \pkg{bench::press} in R support multi-dimensional grid searches, which could be used for computing benchmarks over a grid of data sizes $N$. 
% inability to store results when check=FALSE or  lacking a flexible time limit feature. 
Similarly, packages like \pkg{testComplexity::asymptoticTimings} provide asymptotic complexity estimates but only work for single expressions and lack features like setup argument handling.

To address these gaps and provide a more robust solution for performance analysis in R, we introduce the \pkg{atime} package. \pkg{atime} was designed to offer a set of tools for evaluating the raw performance of code and its scalability and behavior over time. The function \pkg{atime()} allows developers to compare time, memory usage, and other performance metrics for R code that varies based on input size, providing a deeper understanding of how performance scales. Additionally, \pkg{references\_best()} offers asymptotic complexity estimates, giving developers valuable insights into how their algorithms scale as the input size increases. To further support development workflows, \pkg{atime\_versions()} enables developers to track performance across different git versions of their package code, helping them detect performance changes and regressions over time. Finally, \pkg{atime\_pkg()} facilitates continuous performance testing, integrating seamlessly with automated development workflows to ensure consistent quality and performance throughout the development lifecycle.

\code{atime} also integrates directly with GitHub Actions, enabling developers to run \pkg{atime\_pkg} during pull requests. This automated approach ensures that performance regressions are detected early in the development process, saving time and reducing the likelihood of bugs making their way into production. By addressing the limitations of existing tools and providing developers with more flexibility and insight, \pkg{atime} aims to be a powerful and comprehensive solution for performance analysis in R. The package's ability to handle both raw performance metrics and more complex asymptotic performance estimates makes it an indispensable tool for any developer aiming to optimize their R packages.
