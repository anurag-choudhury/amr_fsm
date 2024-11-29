#include <rclcpp/rclcpp.hpp>
#include <sensor_msgs/msg/laser_scan.hpp>
#include <vector>
#include <limits>
#include <cmath>

class BoundingBoxLaser : public rclcpp::Node {
public:
    BoundingBoxLaser() : Node("bounding_box_laser") {
        // Subscribe to LaserScan topic
        RCLCPP_INFO(this->get_logger(), "Creating subscription to laser_scan_topic...");
        subscription_ = this->create_subscription<sensor_msgs::msg::LaserScan>(
            "/pf/scan",
            rclcpp::SensorDataQoS(),
            std::bind(&BoundingBoxLaser::filterLaserScan, this, std::placeholders::_1));

        // Publisher for filtered LaserScan
        publisher_ = this->create_publisher<sensor_msgs::msg::LaserScan>("filtered_scan", 10);
        RCLCPP_INFO(this->get_logger(), "Publisher created for filtered_scan topic.");
    }

private:
    void filterLaserScan(const sensor_msgs::msg::LaserScan::SharedPtr scan_msg) {
        // Log when a new LaserScan message is received
        // RCLCPP_INFO(this->get_logger(), "Received LaserScan message with %zu ranges", scan_msg->ranges.size());

        // Create a copy of the incoming LaserScan to modify
        auto filtered_scan = *scan_msg;

        const float angle_min = scan_msg->angle_min;
        const float angle_increment = scan_msg->angle_increment;

        // Define bounding box dimensions in Cartesian coordinates
        const float x_min = -0.65, x_max = 0.125;   // Forward-backward bounds
        const float y_min = -0.29, y_max = 0.305; // Sideways bounds

        int filtered_count = 0;  // To count the number of filtered points

        for (size_t i = 0; i < filtered_scan.ranges.size(); ++i) {
            float range = filtered_scan.ranges[i];

            if (std::isnan(range) || range < filtered_scan.range_min || range > filtered_scan.range_max) {
                continue; // Skip invalid ranges
            }

            // Calculate the angle for this range
            float angle = angle_min + i * angle_increment;

            // Convert polar coordinates (range, angle) to Cartesian (x, y)
            float x = range * std::cos(angle);
            float y = range * std::sin(angle);

            // Check if the point lies within the bounding box
            if (x >= x_min && x <= x_max && y >= y_min && y <= y_max) {
                // Mark the range as invalid (NaN) and count it
                filtered_scan.ranges[i] = std::numeric_limits<float>::quiet_NaN();
                filtered_count++;
            }
        }

        // Log how many points were filtered out
        // RCLCPP_INFO(this->get_logger(), "Filtered %d points out of %zu", filtered_count, scan_msg->ranges.size());

        // Publish the filtered LaserScan
        publisher_->publish(filtered_scan);
        // RCLCPP_INFO(this->get_logger(), "Published filtered LaserScan message.");
    }

    rclcpp::Subscription<sensor_msgs::msg::LaserScan>::SharedPtr subscription_;
    rclcpp::Publisher<sensor_msgs::msg::LaserScan>::SharedPtr publisher_;
};

int main(int argc, char** argv) {
    rclcpp::init(argc, argv);
    RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "Starting BoundingBoxLaser node...");
    rclcpp::spin(std::make_shared<BoundingBoxLaser>());
    rclcpp::shutdown();
    return 0;
}
