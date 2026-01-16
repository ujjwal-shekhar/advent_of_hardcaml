#include <iostream>
#include <string>
#include <algorithm>

int main() {
    std::string input;
    int max_dig = 0;
    int currans = 0;
    int ans = 0;

    while (std::getline(std::cin, input)) {
        if (input.empty()) {
            break;
        }
    
        for (const auto c : input) {
            int x = c - '0';
            
            currans = std::max(currans, 10 * max_dig + x);
            if (x > max_dig) {
                max_dig = x;
            }
        }

        ans += currans;
        max_dig = 0;
        currans = 0;
    }

    std::cout << ans << std::endl;

    return 0;
}