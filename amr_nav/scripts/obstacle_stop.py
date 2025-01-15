#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan
from geometry_msgs.msg import Twist

class DirectionalSafetyNode(Node):
    def __init__(self):
        super().__init__('directional_safety_node')

        self.lidar_subscriber = self.create_subscription(LaserScan, '/filtered_scan', self.lidar_callback, 10)
        self.cmd_vel_subscriber = self.create_subscription(Twist, '/cmd_vel', self.cmd_vel_callback, 10)
        self.cmd_vel_publisher = self.create_publisher(Twist, '/cmd_vel_safe', 10)

        self.safe_distances = {'front': 0.27, 'left': 0.39, 'right': 0.39, 'back': 0.79}
        self.obstacle_detected = {'front': False, 'left': False, 'right': False, 'back': False}

    def lidar_callback(self, msg):
        ranges = msg.ranges
        num_ranges = len(ranges)

        # Corrected directional slices based on your observation
        back_min = min(ranges[0:int(num_ranges * 30 / 360)] + ranges[-int(num_ranges * 30 / 360):])
        right_min = min(ranges[int(num_ranges * 60 / 360):int(num_ranges * 120 / 360)])
        left_min = min(ranges[int(num_ranges * 240 / 360):int(num_ranges * 300 / 360)])
        front_min = min(ranges[int(num_ranges * 150 / 360):int(num_ranges * 210 / 360)])

        self.obstacle_detected['front'] = front_min < self.safe_distances['front']
        self.obstacle_detected['left'] = left_min < self.safe_distances['left']
        self.obstacle_detected['right'] = right_min < self.safe_distances['right']
        self.obstacle_detected['back'] = back_min < self.safe_distances['back']
        # Log only when an obstacle is detected
        if any(self.obstacle_detected.values()):
            obstacle_info = [
                f"Front: {'YES' if self.obstacle_detected['front'] else 'NO'}",
                f"Left: {'YES' if self.obstacle_detected['left'] else 'NO'}",
                f"Right: {'YES' if self.obstacle_detected['right'] else 'NO'}",
                f"Back: {'YES' if self.obstacle_detected['back'] else 'NO'}"
            ]
            self.get_logger().info(f"Obstacle Detected -> {' | '.join(obstacle_info)}")
    def cmd_vel_callback(self, msg):
        """Override velocity commands with safety checks for immediate halting."""
        safe_twist = Twist()

        # Immediate stop if there is an obstacle in the current movement direction
        if msg.linear.x > 0.0 and self.obstacle_detected['front']:
            safe_twist.linear.x = 0.0  # Stop forward movement
        elif msg.linear.x < 0.0 and self.obstacle_detected['back']:
            safe_twist.linear.x = 0.0  # Stop backward movement
        else:
            safe_twist.linear.x = msg.linear.x  # Allow safe linear movement

        # Handle angular movement for left and right turns
        if msg.angular.z > 0.0 and self.obstacle_detected['left']:
            safe_twist.angular.z = 0.0  # Stop left turn
        elif msg.angular.z < 0.0 and self.obstacle_detected['right']:
            safe_twist.angular.z = 0.0  # Stop right turn
        else:
            safe_twist.angular.z = msg.angular.z  # Allow safe angular movement

        # Publish the adjusted Twist command to immediately reflect obstacle avoidance
        self.cmd_vel_publisher.publish(safe_twist)



def main(args=None):
    rclpy.init(args=args)
    node = DirectionalSafetyNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
