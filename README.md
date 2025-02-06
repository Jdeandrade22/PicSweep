\documentclass{article}
\usepackage{hyperref}

\title{PicSweeper}
\author{Jordan}
\date{January 8, 2025}

\begin{document}

\maketitle

\section{Overview}
\textbf{PicSweeper} is an iOS application that allows users to efficiently manage their photo library using swipe gestures. Users can \textbf{swipe right} to save a photo or \textbf{swipe left} to delete it, streamlining the organization of their gallery.

\section{Features}
\begin{itemize}
    \item \textbf{Swipe-based Photo Management}: Swipe right to keep a photo, swipe left to delete it.
    \item \textbf{Simple and Intuitive UI}: Built with SwiftUI for a responsive and modern experience.
    \item \textbf{Photo Library Access}: Fetches and displays recent images from the device’s gallery.
    \item \textbf{Shuffling and Navigation}: Enables looping through photos and shuffling them for better browsing.
    \item \textbf{Settings Panel}: Users can adjust app preferences through an integrated settings view.
\end{itemize}

\section{Installation}
\begin{enumerate}
    \item Clone the repository:
    \begin{verbatim}
    git clone https://github.com/yourusername/PicSweeper.git
    \end{verbatim}
    \item Open \texttt{PicSweeper.xcodeproj} in Xcode.
    \item Ensure your environment includes:
    \begin{itemize}
        \item Xcode 15 or later
        \item iOS 17 SDK
    \end{itemize}
    \item Build and run the app on a compatible iOS device or simulator.
\end{enumerate}

\section{Usage}
\begin{enumerate}
    \item Launch the application.
    \item Swipe \textbf{right} to save a photo to your library.
    \item Swipe \textbf{left} to delete a photo permanently.
    \item Open \textbf{Settings} to customize app preferences.
\end{enumerate}

\section{Dependencies}
\begin{itemize}
    \item SwiftUI for UI components.
    \item Photos framework for accessing and managing the photo library.
\end{itemize}

\section{License}
This project is licensed under the MIT License - see the \href{https://opensource.org/licenses/MIT}{MIT License} for details.

\section{Author}
Developed by Jordan.

\end{document}
