library(signal)

# CIC filter parameters
R <- 81                        # Decimation factor
M <- 1                         # Differential delay
N <- 6                         # Number of stages

Fc <- 0.097                    # cutoff frequency
htbw <- 0.005                  # half transition bandwidth

# fir2 parameters
k <- kaiserord(c(Fc-htbw, Fc+htbw), c(1, 0), 1/(2^16), 1)
L <- k$n                       # Filter order
Beta <- k$beta                 # Kaiser window parameter

# FIR filter design using fir2
s <- 0.001                     # Step size
fp <- seq(0.0, Fc-htbw, by=s)  # Pass band frequency samples
fs <- seq(Fc+htbw, 0.5, by=s)  # Stop band frequency samples
f <- c(fp, fs)*2               # Normalized frequency samples; 0<=f<=1

Mp <- matrix(1, 1, length(fp)) # Pass band response; Mp[1]=1
Mp[-1] <- abs(M*R*sin(pi*fp[-1]*2/R)/sin(pi*M*fp[-1]*2))^N
Mf <- c(Mp, matrix(0, 1, length(fs)))

h <- fir2(L, f, Mf, window=kaiser(L+1, Beta))

h <- h / sum(h)

# Print filter coefficients
paste(sprintf("%.10e", h), collapse=", ")

fh <- freqz(h)

op <- par(mfrow = c(2, 1))

plot(f, 20*log10(Mf), type = "b", ylab = "dB", xlab = "Frequency", xlim = c(0.20, 0.22), ylim = c(-125, 5))
lines(fh$f / pi, 20*log10(abs(fh$h)), col = "blue")
grid()

plot(f, 20*log10(Mf), type = "b", ylab = "dB", xlab = "Frequency", xlim = c(0.18, 0.20), ylim = c(-5, 5))
lines(fh$f / pi, 20*log10(abs(fh$h)), col = "blue")
grid()

par(op)
