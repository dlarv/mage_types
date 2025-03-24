>[!important] Addon
>This was made into an addon for easier portability.

Used to make separate/non-contiguous rooms, like inside a building.

_RoomPortal_: Area3D
- Can be either 1 or 2 way.

Two Way:
RoomPortal
>CollisionShape3D
>>Marker3D
>CollisionShape3D
>>Marker3D

One Way:
>CollisionShape3D
>>Marker3D
> Marker3D