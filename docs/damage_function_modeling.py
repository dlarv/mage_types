import matplotlib.pyplot as plt

def with_extra_power(att_lvl, def_lvl):
    strength = 30
    power = strength / 4 + (att_lvl * strength / 10)
    m_def = 10 + 3*def_lvl
    m_att = 10 + 3*att_lvl
    d_hp = 50 + 3*def_lvl

    output = power * m_att/m_def
    return output / d_hp

def no_extra_power(att_lvl, def_lvl):
    strength = 30
    power = strength / 4
    m_def = 10 + 3*def_lvl
    m_att = 10 + 3*att_lvl
    d_hp = 50 + 3*def_lvl

    output = power * m_att/m_def
    return output / d_hp


points_a = []
points_b = []
for x in range(0, 100):
    points_a.append(with_extra_power(x, x - 2))
    points_b.append(no_extra_power(x, x - 2))

# plt.plot(range(0, 100), range(0, 100), "r--", points_a, "b--", points_b)
plt.plot(points_a)
plt.plot(points_b)
plt.show()
