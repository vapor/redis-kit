import DatabaseKit

extension DatabaseIdentifier {
    public static var redis: DatabaseIdentifier<RedisDatabase> {
        return .init("redis")
    }
}
