#include <iostream>
#include <string>
#include <algorithm>
#include <vector>

int main() {
    std::string input;
    long long ans = 0;

    while (std::getline(std::cin, input)) {
        if (input.empty()) {
            break;
        }

        // dp[i] stores the max value for a subsequence of length i+1
        // dp[0] is max 1-digit number, dp[11] is max 12-digit number
        std::vector<long long> dp(12, 0);

        for (const auto c : input) {
            long long x = c - '0';
            
            // dp(i) can be formed by appending x to dp(i-1)
            // or by not including x at all, its a take/not-take dp!
            for (int i = 11; i >= 1; --i) {
                dp[i] = std::max(dp[i], dp[i-1] * 10 + x);
            }

            dp[0] = std::max(dp[0], x); // Base case
        }

        ans += dp[11];
    }

    std::cout << ans << std::endl;

    return 0;
}